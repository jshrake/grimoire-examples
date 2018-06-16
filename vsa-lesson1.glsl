// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[[pass]]
clear     = [0.0, 0.0, 0.0, 1.0]
blend     = {src = "one", dst = "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "points", count = 1000}
*/

#ifdef GRIM_VERTEX
#define GRIM_OVERRIDE_MAIN
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution

void main() {
    float down = floor(sqrt(vertexCount));
    float across = floor(vertexCount / down);
    float x = mod(vertexId, across);
    float y = floor(vertexId / across);
    float u = x / (across - 1.0);
    float v = y / (across - 1.0);
    float ux = 2. * u - 1.;
    float vy = 2. * v - 1.;
    gl_Position = vec4(ux, vy, 0.0, 1.0);
    gl_PointSize = 10.0;
    gl_PointSize *= 20. / across;
    gl_PointSize *= resolution.x / 600.;
}
#endif

#ifdef GRIM_FRAGMENT
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
#endif