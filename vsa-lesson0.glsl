// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License.

/*
[[pass]]
clear     = [0.0, 0.0, 0.0, 1.0]
draw      = {mode = "triangles", count = 2}
*/

#ifdef GRIM_VERTEX
#define GRIM_OVERRIDE_MAIN
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution

vec2 quad(float id) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
  float x = ux;
  float y = vy;
  // generate vertices [-1, 1] x [-1, 1]
  return 2. * mod(vec2(x, y), vec2(2, 2)) - 1.;
}

void main() { gl_Position = vec4(0.5 * quad(vertexId), 0, 1); }
#endif

#ifdef GRIM_FRAGMENT
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = vec4(sin(iTime), 0.3, cos(iTime), 1.0);
}
#endif