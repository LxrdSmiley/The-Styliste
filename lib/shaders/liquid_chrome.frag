#include <flutter/runtime_effect.glsl>

// Liquid chrome / metallic surface shader
// Used for: premium UI accents, gold/silver hardware on garments, HQ trophies
// GDD §3.0 — Premium mobile experience visual language

uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uBaseColor;    // e.g. gold: (0.788, 0.659, 0.298)
uniform float uReflectivity;

out vec4 fragColor;

vec3 chromeReflection(vec2 uv, float time) {
  float r = sin(uv.x * 10.0 + time) * 0.5 + 0.5;
  float g = cos(uv.y * 8.0 + time * 1.3) * 0.5 + 0.5;
  float b = sin((uv.x + uv.y) * 6.0 - time * 0.8) * 0.5 + 0.5;
  return vec3(r, g, b);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;

  vec4 baseTexture = texture(uTexture, uv);
  vec3 reflection = chromeReflection(uv, uTime);

  vec3 chrome = mix(uBaseColor, reflection, uReflectivity * 0.6);
  float fresnel = pow(1.0 - abs(dot(normalize(vec2(0.5) - uv), vec2(0.0, 1.0))), 3.0);
  chrome += fresnel * uBaseColor * 0.4;

  fragColor = vec4(mix(baseTexture.rgb, chrome, uReflectivity), baseTexture.a);
}
