// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
void main() {
    float x = -1.0 + float((gl_VertexID & 1) << 2);
    float y = -1.0 + float((gl_VertexID & 2) << 1);
    vec2 xy = vec2(x,y);
    vec2 scale = 0.6 + 0.4 * sin(iTime) * vec2(1.0);
    gl_Position = vec4(scale * xy, 0, 1);
}
#endif

#ifdef GRIM_FRAGMENT
out vec4 target0;
void main() {
  target0 = vec4(0.5, 0.0, 0.5 + 0.5 * sin(iTime), 1.0);
}
#endif
