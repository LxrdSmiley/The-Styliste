#include <flutter/runtime_effect.glsl>

// Vantablack deep absorption material shader
// Used for: premium dark garment rendering, obsidian UI surfaces, Onboarding Screen 1
// GDD §1.1 "Obsidian Gate" — full-bleed black with gold particle scan beam

uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform float uAbsorption;     // 0.0 = matte black, 1.0 = slight depth texture
uniform vec3 uAccentColor;     // gold scan beam color: (0.788, 0.659, 0.298)
uniform float uScanPosition;   // 0.0–1.0 vertical scan beam position

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;

  // Deep black base — minimal light return
  vec4 base = texture(uTexture, uv);
  vec3 dark = base.rgb * (1.0 - uAbsorption * 0.97);

  // Depth texture — micro surface variation for realism
  float microSurface = sin(uv.x * 200.0) * cos(uv.y * 200.0) * 0.003 * uAbsorption;
  dark += vec3(microSurface);

  // Gold scan beam (used in Obsidian Gate onboarding screen)
  float beamDist = abs(uv.y - uScanPosition);
  float beam = exp(-beamDist * 80.0) * 0.6;
  vec3 result = dark + uAccentColor * beam;

  fragColor = vec4(result, base.a);
}
