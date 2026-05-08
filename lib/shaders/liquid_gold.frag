#include <flutter/runtime_effect.glsl>

// GDD v6 §1.1 — Liquid Gold Ripple Shader
// Aurelian Sanctuary: Champagne Gold (#F7E7CE) viscous liquid with touch ripple
// Replaces vantablack.frag — Alabaster Standard biometric feedback

uniform float uTime;           // Animation time in seconds
uniform vec2 uResolution;      // Screen resolution
uniform vec2 uTouch;           // Normalized touch position (0.0-1.0)
uniform float uCharge;         // Charge progress 0.0 (start) to 1.0 (full)

out vec4 fragColor;

// -----------------------------------------------------------------------------
// Simplex Noise for organic liquid movement
// -----------------------------------------------------------------------------

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626, // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    i = mod289(i);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
                     + i.x + vec3(0.0, i1.x, 1.0));
    
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// -----------------------------------------------------------------------------
// Fractal Brownian Motion for layered liquid texture
// -----------------------------------------------------------------------------

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * snoise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

// -----------------------------------------------------------------------------
// Liquid Gold Shader
// -----------------------------------------------------------------------------

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    
    // Champagne Gold base color: #F7E7CE
    vec3 champagneGold = vec3(0.969, 0.906, 0.808);
    vec3 ivory = vec3(1.0, 0.941, 0.941);
    
    // Time-based liquid movement (slow, viscous)
    float time = uTime * 0.15;
    
    // Layered noise for liquid surface
    vec2 noiseCoord = uv * 3.0 + vec2(time * 0.5, time * 0.3);
    float noise1 = fbm(noiseCoord);
    float noise2 = fbm(noiseCoord * 1.5 + vec2(10.0, 5.0));
    float noise3 = snoise(uv * 5.0 + time);
    
    // Combine noise layers for depth
    float combinedNoise = noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2;
    
    // Base liquid color variation
    vec3 liquidColor = mix(
        champagneGold,
        champagneGold * 1.15, // Lighter highlights
        combinedNoise * 0.5 + 0.5
    );
    
    // Add warm undertones
    liquidColor = mix(
        liquidColor,
        vec3(0.98, 0.88, 0.78), // Warm gold
        smoothstep(-0.3, 0.5, noise1) * 0.3
    );
    
    // -----------------------------------------------------------------------------
    // Touch Ripple Effect
    // -----------------------------------------------------------------------------
    
    // Calculate distance from touch point
    vec2 touchPos = uTouch;
    float dist = length(uv - touchPos);
    
    // Ripple parameters based on charge
    float rippleSpeed = 1.5;
    float rippleSize = 0.3 + uCharge * 0.4; // Expands as charge increases
    float rippleIntensity = uCharge * 0.8;  // Stronger as charge increases
    
    // Expanding ring
    float ringPhase = uTime * rippleSpeed;
    float ringDist = dist * 8.0 - ringPhase;
    float ring = sin(ringDist) * exp(-dist * 3.0) * rippleIntensity;
    
    // Secondary shimmer ring
    float shimmerPhase = uTime * rippleSpeed * 1.3 + 1.0;
    float shimmerRing = sin(dist * 15.0 - shimmerPhase) * 0.5 * uCharge;
    shimmerRing *= exp(-dist * 4.0);
    
    // Viscosity effect — liquid thickens near touch
    float viscosity = smoothstep(rippleSize, 0.0, dist) * uCharge * 0.3;
    
    // Combine ripple effects
    float rippleEffect = ring + shimmerRing + viscosity;
    
    // Apply ripple to color (brighten and shift)
    vec3 rippleColor = mix(
        liquidColor,
        ivory, // Bright center
        clamp(rippleEffect * 0.5 + 0.2, 0.0, 0.6)
    );
    
    // Add specular highlights on ripple crests
    float specular = pow(max(0.0, ring), 3.0) * 0.8;
    rippleColor += vec3(specular);
    
    // -----------------------------------------------------------------------------
    // Final Output
    // -----------------------------------------------------------------------------
    
    // Edge vignette for focus
    float vignette = 1.0 - smoothstep(0.4, 1.2, length(uv - 0.5));
    rippleColor *= 0.9 + vignette * 0.1;
    
    // Fade to white based on charge (for transition)
    vec3 finalColor = mix(
        rippleColor,
        vec3(1.0, 1.0, 1.0), // Pure white
        smoothstep(0.7, 1.0, uCharge) * 0.3
    );
    
    fragColor = vec4(finalColor, 1.0);
}
