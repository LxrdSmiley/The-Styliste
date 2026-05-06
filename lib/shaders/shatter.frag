#include <flutter/runtime_effect.glsl>

// Shatter / glass-break transition shader
// Used for: Onboarding Screen 7 (Specialization) — irreversible path choice shatter animation
// GDD §1.1 "Specialization Selection" — shatter animation on path confirmation

uniform sampler2D uTexture;
uniform float uProgress;    // 0.0 = intact, 1.0 = fully shattered
uniform vec2 uResolution;
uniform vec2 uImpactPoint;  // normalised UV of shatter origin
uniform vec3 uShardColor;   // tint for shard edges (gold: 0.788, 0.659, 0.298)

out vec4 fragColor;

// Pseudo-random hash for shard boundary generation
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Voronoi-based shard pattern
float voronoi(vec2 uv) {
  vec2 cell = floor(uv * 12.0);
  vec2 frac = fract(uv * 12.0);
  float minDist = 8.0;
  for (float x = -1.0; x <= 1.0; x += 1.0) {
    for (float y = -1.0; y <= 1.0; y += 1.0) {
      vec2 neighbor = vec2(x, y);
      vec2 point = vec2(hash(cell + neighbor), hash(cell + neighbor + vec2(1.7, 9.2)));
      float dist = length(frac - neighbor - point);
      minDist = min(minDist, dist);
    }
  }
  return minDist;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;

  float dist = distance(uv, uImpactPoint);
  float shardBoundary = voronoi(uv);

  // Displacement grows outward from impact point as progress increases
  float dispStrength = uProgress * dist * 0.08;
  vec2 displaced = uv + normalize(uv - uImpactPoint) * dispStrength * shardBoundary;

  vec4 color = texture(uTexture, clamp(displaced, 0.0, 1.0));

  // Shard edge glow
  float edge = smoothstep(0.08, 0.12, shardBoundary) * uProgress;
  color.rgb = mix(color.rgb, uShardColor, edge * 0.7);

  // Fade out fully shattered regions
  float fade = 1.0 - smoothstep(0.6, 1.0, uProgress * dist * 2.0);
  color.a *= fade;

  fragColor = color;
}
