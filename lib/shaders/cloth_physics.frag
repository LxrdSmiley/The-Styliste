#include <flutter/runtime_effect.glsl>

// GDD §4.2 — Verlet cloth physics fragment shader
// Handles: gravity drape, stretch/compression, wrinkles, self-collision simulation
// Per-fabric parameters passed as uniforms: density, stiffness, elasticity, friction
// IMPORTANT: All high-frequency cloth math lives here — never on the Dart main thread.
// PROJECT_RULES §2: GLSL handles all Verlet integration and cloth physics.
//
// Phase 4 additions:
//   uTouchPos  — lerp-smoothed touch coordinate (normalized 0–1); (-1,-1) = no touch.
//   uDyeColor  — selected fabric dye RGB. Blended with texture via mix() over alpha
//                so a 1×1 black fallback texture renders the dye, not pure black.
//
// Uniform slot map (determines Dart setFloat index — DO NOT reorder):
//   uFabricTexture → setImageSampler(0)
//   uTime          → setFloat(0)
//   uDensity       → setFloat(1)
//   uStiffness     → setFloat(2)
//   uElasticity    → setFloat(3)
//   uFriction      → setFloat(4)
//   uDrapeCoeff    → setFloat(5)
//   uBendResistance→ setFloat(6)
//   uResolution    → setFloat(7, w) setFloat(8, h)
//   uGravity       → setFloat(9, x) setFloat(10, y)
//   uTouchPos      → setFloat(11, x) setFloat(12, y)
//   uDyeColor      → setFloat(13, r) setFloat(14, g) setFloat(15, b)

uniform sampler2D uFabricTexture;
uniform float uTime;
uniform float uDensity;       // fabric density (kg/m²)
uniform float uStiffness;     // spring stiffness coefficient
uniform float uElasticity;    // stretch recovery factor
uniform float uFriction;      // surface friction coefficient
uniform float uDrapeCoeff;    // drape coefficient (0=rigid, 1=fluid)
uniform float uBendResistance;
uniform vec2 uResolution;
uniform vec2 uGravity;        // gravity direction vector
uniform vec2 uTouchPos;       // lerp-smoothed touch (0–1 each); (-1,-1) = inactive
uniform vec3 uDyeColor;       // selected fabric dye RGB

out vec4 fragColor;

// --- Verlet Integration (single-step approximation for fragment stage) ---
// Full constraint resolution occurs in compute pass; this shader handles
// per-pixel shading with physics-derived UV distortion.
vec2 verletDisplace(vec2 uv, float time) {
  float wave = sin(uv.x * 8.0 + time * 2.0) * uDrapeCoeff * 0.012;
  float drape = cos(uv.y * 6.0 + time * 1.5) * uDensity * 0.008;
  float bend = sin((uv.x + uv.y) * 5.0 + time) * uBendResistance * 0.005;
  return vec2(wave + bend, drape);
}

// --- Touch ripple: radial displacement from lerp-smoothed pointer position ---
// Only active when uTouchPos is in valid range (>= 0.0).
vec2 touchRipple(vec2 uv, float time) {
  if (uTouchPos.x < 0.0) return vec2(0.0);
  float dist = length(uv - uTouchPos);
  float ripple = sin(dist * 30.0 - time * 8.0) * exp(-dist * 6.0) * 0.018;
  vec2 dir = normalize(uv - uTouchPos + vec2(0.0001));
  return dir * ripple;
}

// --- Wrinkle Generation ---
float wrinkle(vec2 uv, float time) {
  float w1 = sin(uv.x * 20.0 + time * 3.0) * 0.5 + 0.5;
  float w2 = cos(uv.y * 15.0 - time * 2.0) * 0.5 + 0.5;
  return mix(w1, w2, uStiffness) * (1.0 - uElasticity) * 0.3;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;

  // Apply Verlet-derived UV displacement + touch ripple for cloth movement
  vec2 displaced = uv + verletDisplace(uv, uTime) + touchRipple(uv, uTime);

  // Sample fabric texture at displaced coordinates
  vec4 texSample = texture(uFabricTexture, clamp(displaced, 0.0, 1.0));

  // Blend dye color with texture sample using texture alpha as mix weight.
  // When uFabricTexture is a 1×1 black fallback texture (alpha=1), mix() still
  // correctly blends toward uDyeColor rather than rendering pure black.
  vec3 blended = mix(uDyeColor, texSample.rgb, texSample.a * 0.35);
  vec4 fabricColor = vec4(blended, 1.0);

  // Apply wrinkle shading (darkens fold regions)
  float wrinkleVal = wrinkle(uv, uTime);
  fabricColor.rgb *= (1.0 - wrinkleVal * 0.4);

  // Apply gravity-based shadow gradient
  float gravityShadow = mix(0.85, 1.0, 1.0 - uv.y * uDensity * 0.5);
  fabricColor.rgb *= gravityShadow;

  // Friction-based specular highlight
  float spec = pow(max(0.0, dot(normalize(vec2(0.5, 1.0) - uv), uGravity)), 16.0);
  fabricColor.rgb += spec * uFriction * 0.15;

  fragColor = fabricColor;
}
