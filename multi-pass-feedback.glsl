// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.

/*
[A]
buffer = true

[[pass]]
buffer = "A"
iChannel0 = "A"

[[pass]]
iChannel0 = "A"
*/

#ifdef GRIM_PASS_0
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  if (iFrame == 0) {
    fragColor = vec4(1.0, 0.0, 1.0, 1.0);
  } else {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
  }
  if (mod(iFrame, 30) == 0) {
    fragColor = 1.0 - fragColor;
  }
}
#endif

#ifdef GRIM_PASS_1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = texture(iChannel0, fragCoord / iChannel0_Resolution.xy);
}
#endif