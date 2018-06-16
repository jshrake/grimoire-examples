// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[r]
image = "resources/red.png"

[g]
image = "resources/green.png"

[b]
image = "resources/blue.png"

[[pass]]
iChannel0 = "r"
iChannel1 = "g"
iChannel2 = "b"
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  fragColor = texture(iChannel0, uv) + texture(iChannel1, uv) + texture(iChannel2, uv);
}
