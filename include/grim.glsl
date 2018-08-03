#define PI 3.14159265359
#define DEG2RAD 0.01745329251
#define RAD2DEG 57.2957795131

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

// hash functions
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(.1031, .1030, .0973, .1099)
float hash11(float p) {
  vec3 p3 = fract(vec3(p) * HASHSCALE1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
//  1 out, 2 in...
float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * HASHSCALE1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
//  1 out, 3 in...
float hash13(vec3 p3) {
  p3 = fract(p3 * HASHSCALE1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
//  2 out, 1 in...
vec2 hash21(float p) {
  vec3 p3 = fract(vec3(p) * HASHSCALE3);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.xx + p3.yz) * p3.zy);
}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.xx + p3.yz) * p3.zy);
}

//----------------------------------------------------------------------------------------
///  2 out, 3 in...
vec2 hash23(vec3 p3) {
  p3 = fract(p3 * HASHSCALE3);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.xx + p3.yz) * p3.zy);
}

//----------------------------------------------------------------------------------------
//  3 out, 1 in...
vec3 hash31(float p) {
  vec3 p3 = fract(vec3(p) * HASHSCALE3);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.xxy + p3.yzz) * p3.zyx);
}

//----------------------------------------------------------------------------------------
///  3 out, 2 in...
vec3 hash32(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
  p3 += dot(p3, p3.yxz + 19.19);
  return fract((p3.xxy + p3.yzz) * p3.zyx);
}

//----------------------------------------------------------------------------------------
///  3 out, 3 in...
vec3 hash33(vec3 p3) {
  p3 = fract(p3 * HASHSCALE3);
  p3 += dot(p3, p3.yxz + 19.19);
  return fract((p3.xxy + p3.yxx) * p3.zyx);
}

//----------------------------------------------------------------------------------------
// 4 out, 1 in...
vec4 hash41(float p) {
  vec4 p4 = fract(vec4(p) * HASHSCALE4);
  p4 += dot(p4, p4.wzxy + 19.19);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

//----------------------------------------------------------------------------------------
// 4 out, 2 in...
vec4 hash42(vec2 p) {
  vec4 p4 = fract(vec4(p.xyxy) * HASHSCALE4);
  p4 += dot(p4, p4.wzxy + 19.19);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

//----------------------------------------------------------------------------------------
// 4 out, 3 in...
vec4 hash43(vec3 p) {
  vec4 p4 = fract(vec4(p.xyzx) * HASHSCALE4);
  p4 += dot(p4, p4.wzxy + 19.19);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

//----------------------------------------------------------------------------------------
// 4 out, 4 in...
vec4 hash44(vec4 p4) {
  p4 = fract(p4 * HASHSCALE4);
  p4 += dot(p4, p4.wzxy + 19.19);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

float thash12(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 thash33(vec3 p) {
  p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)),
           dot(p, vec3(113.5, 271.9, 124.6)));
  return fract(sin(p) * 43758.5453123);
}
#ifdef GRIM_VERTEX
// VERTEX SHADER ART conversions
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution
#define time iTime
#endif