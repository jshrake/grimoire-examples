// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[webcam]
webcam = true

[[pass]]
iChannel0 = "webcam"
*/
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 texCoord = fragCoord / iResolution.xy;
  texCoord = 1.0 - texCoord;
  fragColor = texture(iChannel0, texCoord);
}
