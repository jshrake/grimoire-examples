// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.
/*
[A]
buffer = true
attachments = 3
format = "u8"

[[pass]]
buffer =  "A"

[[pass]]
iChannel0 = {resource = "A", attachment = 0}
iChannel1 = {resource = "A", attachment = 1}
iChannel2 = {resource = "A", attachment = 2}
*/

#ifdef GRIM_FRAGMENT_PASS_0
#define GRIM_OVERRIDE_MAIN
layout(location = 0) out vec4 target0;
layout(location = 1) out vec4 target1;
layout(location = 2) out vec4 target2;

void main() {
  target0 = vec4(1.0, 0.0, 0.0, 1.0);
  target1 = vec4(0.0, 0.5 * (1.0 + sin(iTime)), 0.0, 1.0);
  target2 = vec4(0.0, 0.0, 1.0, 1.0);
}
#endif

#ifdef GRIM_PASS_1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec4 target0 = texture(iChannel0, uv);
  vec4 target1 = texture(iChannel1, uv);
  vec4 target2 = texture(iChannel2, uv);
  fragColor = target0 + target1 + target2;
}
#endif
