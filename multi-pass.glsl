// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.

// Notice that you can specify the width and height of the framebuffer color
// attachments for each pass, except for the last. The last pass draws to the
// default framebuffer and has a width and height equal to the window width and
// height

/*

[A]
width = 1
height = 1
format = "u8"

[B]
width = 1
height = 1
format = "u8"

[C]
width = 1
height = 1
format = "u8"

[[pass]]
buffer = "A"

[[pass]]
buffer = "B"

[[pass]]
buffer = "C"

[[pass]]
iChannel0 = {resource = "A"}
iChannel1 = {resource = "B"}
iChannel2 = {resource = "C"}
*/

#ifdef GRIM_PASS_0
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = vec4(0.0, 0.0, 1.0, 0.0);
}
#endif

#ifdef GRIM_PASS_1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = vec4(0.0, sin(iTime), 0.0, 1.0);
}
#endif

#ifdef GRIM_PASS_2
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = vec4(0.5 + 0.5 * cos(iTime), 0.0, 1.0, 1.0);
}
#endif

#ifdef GRIM_PASS_3
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec4 c0 = texture(iChannel0, fragCoord);
  vec4 c1 = texture(iChannel1, fragCoord);
  vec4 c2 = texture(iChannel2, fragCoord);
  fragColor = 0.333 * (c0 + c1 + c2);
}
#endif
