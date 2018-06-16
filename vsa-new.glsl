/*
[[pass]]
clear     = [0.0, 0.0, 0.0, 1.0]
blend     = {src = "one", dst = "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "points", count = 12000}
*/
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
// #defines to paper over uniform name differences between grimoire and vertex shader art
#define vertexId gl_VertexID
#define resolution iResolution
#define time iTime
#define mouse (iMouse/iResolution.xyxy).xy
#define vertexCount iVertexCount
out vec4  v_color;
void main() {
    v_color = vec4(1.0, 1.0, 1.0, 1.0);
    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
}
#endif

#ifdef GRIM_FRAGMENT
in vec4  v_color;
out vec4 fragColorOut;
void main() {
  fragColorOut = v_color;
}
#endif
