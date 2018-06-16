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

mat3 rotX(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c);
}

mat3 rotY(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);
}

mat3 rotZ(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);
}

mat3 scale(float s) { return mat3(s); }
mat3 scale2(vec2 s) { return scale(s.x) * scale(s.y); }
mat3 scale3(vec3 s) { return scale(s.x) * scale(s.y) * scale(s.z); }
mat4 transpose(vec3 pos) {
  return mat4(vec4(1, 0, 0, 0), vec4(0, 1, 0, 0), vec4(0, 0, 1, 0),
              vec4(pos, 1));
}

mat4 frustum(float left, float right, float bottom, float top, float near,
             float far) {
  float x = 2 * near / (right - left);
  float y = 2 * near / (top - bottom);
  float A = (right + left) / (right - left);
  float B = (top + bottom) / (top - bottom);
  float C = -(far + near) / (far - near);
  float D = -2 * far * near / (far - near);
  // clang-format off
  return mat4x4(
    x, 0, 0, 0,
    0, y, 0, 0,
    A, B, C, -1,
    0, 0, D, 0
  );
  // clang-format on
}

mat4 perspective(float hfov_deg, float aspect, float near, float far) {
  float hfov_rad = DEG2RAD * hfov_deg;
  float vfov_rad = 2.0f * atan(tan(hfov_rad * 0.5f) / aspect);
  // Tangent of half-FOV
  float tangent = tan(0.5 * vfov_rad);
  // Half the height of the near plane
  float height = near * tangent;
  // Half the width of the near plane
  float width = height * aspect;
  return frustum(-width, width, -height, height, near, far);
}

mat4 lookat(vec3 eye, vec3 look, vec3 up) {
  vec3 normal = normalize(look - eye);
  vec3 over = normalize(cross(up, normal));
  up = normalize(cross(normal, over));
  return mat4(vec4(over, 0), vec4(up, 0), vec4(normal, 0), vec4(eye, 1));
}

vec2 quad(float id) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
  float x = ux;
  float y = vy;
  // generate vertices [-1, 1] x [-1, 1]
  return 2. * mod(vec2(x, y), vec2(2, 2)) - 1.;
}

vec2 quad_uv(float id) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
  float x = ux;
  float y = vy;
  // generate vertices [0, 1] x [0, 1]
  return mod(vec2(x, y), vec2(2, 2));
}
float rotr3(float x, float n) {
  return floor(x / pow(2.0, n)) + mod(x * pow(2.0, 3.0 - n), 8.0);
}

float cube_id(float id) { return floor(id / (36.)); }
float cube_face_id(float id) { return mod(floor(id / 6.), 6.); }
vec3 cube(float id) { return vec3(id); }
vec3 cube_normal(float id) { return vec3(1); }

mat3 arcball() {
  float x = (iMouse.x / iResolution.x) * 2.0 * PI;
  float y = (iMouse.y / iResolution.y - 0.5) * PI;
  return rotX(y) * rotY(x);
}

vec3 coordinate_frame_point(float id) {
  vec3 point = vec3(0, 0, 0);
  int index = int(floor(id / 2));
  float value = mod(id, 2);
  point[index] = value;
  return point;
}

vec3 coordinate_frame_color(float id) {
  vec3 color = vec3(0, 0, 0);
  int index = int(floor(id / 2));
  color[index] = 1.;
  return color;
}

mat4 projection() { return perspective(90., 1., 0.1, 1000.); }
mat4 camera() {
  vec3 eye = vec3(0, 0, -10);
  vec3 look = vec3(0, 0, 0);
  vec3 up = vec3(0, 1, 0);
  return lookat(eye, look, up) * mat4(arcball());
}
#endif

// PASS 0: Ground plane
#ifdef GRIM_PASS_0
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
out vec2 v_uv;
void main() {
  mat4 Projection = projection();
  mat4 Camera = camera();
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
  mat4 Camera = camera();
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
