// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#ifdef GRIM_FRAGMENT
#define GRIM_OVERRIDE_MAIN
out vec4 fragColor;
void main() {
  fragColor = vec4(0.0, 0.0, 1.0, 1.0);
}
#endif
