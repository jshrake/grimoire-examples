/*
[r]
image = "resources/red.png"

[g]
image = "resources/green.png"

[b]
image = "resources/blue.png"

[val]
uniform = 1.0
min     = 0.0
max     = 0.0

[[pass]]
iChannel0 = "r"
iChannel1 = "g"
iChannel2 = "b"
*/
// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  fragColor = val * texture(iChannel0, uv) + texture(iChannel1, uv) +
              texture(iChannel2, uv);
}
