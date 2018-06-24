// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License
/*
[scene]
buffer = true

# ground
[[pass]]
clear     = [0.38, 0.2, 0.7, 1.0]
blend     = {src = "src-alpha",  dst= "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "triangles", count = 2}
buffer    = "scene"

# quad
[[pass]]
blend     = {src = "src-alpha",  dst= "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "triangles", count = 2}
buffer    = "scene"

# ui
[[pass]]
blend     = {src = "src-alpha",  dst= "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "lines", count = 3}
buffer    = "scene"

# post-fx
[[pass]]
iChannel0 = "scene"
*/

#define PI 3.14159265359
#define DEG2RAD 0.01745329251
#define RAD2DEG 57.2957795131

#ifdef GRIM_VERTEX
// VERTEX SHADER ART conversions
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution
#define time iTime
#include <grim.glsl>
#endif

// PASS 0: Ground plane
#ifdef GRIM_PASS_0
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
out vec2 v_uv;
void main() {
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  gl_Position = Projection * Camera * transpose(vec3(0, -1, 0)) *
                mat4(rotX(0.5 * PI)) * vec4(1000. * quad(vertexId), 0, 1);
  v_uv = quad_uv(vertexId);
}
#endif

#ifdef GRIM_FRAGMENT
in vec4 v_color;
in vec2 v_uv;
out vec4 fragColor;
void main() {
  // ground plane w/ checkerboard pattern
  vec2 pos = floor(v_uv * 2000.0);
  float pattern = mod(pos.x + mod(pos.y, 2.0), 2.0);
  fragColor = pattern * vec4(1.);
  fragColor.a = 1.;
}
#endif
#endif

// PASS 1: The QUAD
#ifdef GRIM_PASS_1
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
void main() {
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  gl_Position = Projection * Camera * vec4(quad(vertexId), 0, 1);
  v_color = vec4(1, 0, 0, 1);
}
#endif

#ifdef GRIM_FRAGMENT
in vec4 v_color;
out vec4 fragColor;
void main() { fragColor = v_color; }
#endif
#endif

// PASS 2: The UI
#ifdef GRIM_PASS_2
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
void main() {
  float id = vertexId;
  float ar = iResolution.z;
  // Translate to the upper-left corner and shrink it down
  mat4 TS = transpose(vec3(-0.85, 0.85, 0.)) * mat4(scale(.1));
  vec3 vertex = arcball() * coordinate_frame_point(id);
  gl_Position = TS * vec4(vertex, 1);
  v_color = vec4(coordinate_frame_color(id), 1.);
}
#endif

#ifdef GRIM_FRAGMENT
in vec4 v_color;
out vec4 fragColor;
void main() { fragColor = v_color; }
#endif
#endif

// PASS 3: Post
#ifdef GRIM_PASS_3
#ifdef GRIM_FRAGMENT
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  fragColor = texture(iChannel0, uv);
}
#endif
#endif
