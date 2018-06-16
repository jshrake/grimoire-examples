// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.

// clang-format off
/*
[cam]
pipeline = "autovideosrc ! video/x-raw,format=BGRA ! appsink name=appsink async=false sync=false"

[[pass]]
iChannel0 = "cam"
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 color_uv = 1.0 - fragCoord / iResolution.xy;
  vec3 color = texture(iChannel0, color_uv).rgb;
  fragColor = vec4(color, 1.0);
}
