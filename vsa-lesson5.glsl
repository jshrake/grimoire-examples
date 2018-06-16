// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[[pass]]
clear     = [0.0, 0.0, 0.0, 1.0]
blend     = {src = "one", dst = "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "triangles", count = 20}
*/
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution
#define time iTime

out vec4 v_color;



void main () {
    float id = vertexId;
    float ux = floor(id / 6.) + mod (id, 2.);
    float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
    float x = ux;
    float y = vy;
    vec2 xy = vec2(x, y);
    gl_Position = vec4(0.1 * xy, 0., 1.);
    v_color = vec4(1.0, 0.0, 0.0, 1.0);
}

#endif

#ifdef GRIM_FRAGMENT
in vec4 v_color;
out vec4 fragColor;
void main() {
    fragColor = v_color;
}
#endif