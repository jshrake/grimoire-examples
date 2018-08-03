// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License
/*
[[uniform]]

[scene]
buffer      = true
format      = "f32"
attachments = 3

# ground
[[pass]]
clear      = [0.0, 0.0, 0.0, 1.0]
draw      = {mode = "triangles", count = 2}
depth     = "less"
buffer    = "scene"

# quads
[[pass]]
draw      = {mode = "triangles", count = 100000}
depth     = "less"
buffer    = "scene"

# ui
[[pass]]
draw      = {mode = "lines", count = 3}
buffer    = "scene"

# post-fx
[[pass]]
gColor      = {resource= "scene", attachment = 0, filter = "nearest"}
gPosition   = {resource= "scene", attachment = 1, filter = "nearest"}
gNormal     = {resource= "scene", attachment = 2, filter = "nearest"}
*/

#include <grim.glsl>

#define PLANE_SIDE_LEN 200.0
#define CAMERA_POS vec3(0.0, 0.0, -50.0)
#define CAMERA_LOOKAT vec3(0.0, 0.0, 0.0)

mat4 projection() { return perspective(90., 1., 0.1, 1000.); }
mat4 camera() {
  vec3 eye = CAMERA_POS;
  vec3 look = CAMERA_LOOKAT;
  vec3 up = vec3(0, 1, 0);
  return lookat(eye, look, up);
}

// PASS 0: Ground plane
#ifdef GRIM_PASS_0
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
out vec4 v_position;
out vec4 v_normal;
void main() {
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  mat4 Model = mat4(1.0);
  mat3 Normal = transpose(inverse(mat3(Model)));

  vec4 model = vec4(0.5 * PLANE_SIDE_LEN * quad(vertexId), 0, 1);
  v_color = vec4(0.9, 0.0, 0.4, 0.1);
  v_position = Model * model;
  v_normal = normalize(vec4(Normal * vec3(0.0, 0.0, 1.0), 1.0));
  gl_Position = Projection * Camera * v_position;
}
#endif // GRIM_VERTEX

#endif // GRIM_PASS_0

// PASS 1: The quads animating along the edges
#ifdef GRIM_PASS_1
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX

vec2 grid(float across, float id) {
  // For across = 2, we want:
  // x -> [0; 6], [1; 6]
  // y -> [0; 6], [1; 6]
  // quad 0, id = 0 - 6
  // x -> 0
  // y -> 0
  // quad 1, id = 6 - 12
  // x -> 1
  // y -> 0
  // quad 2, id = 12 - 18
  // x -> 0
  // y -> 1
  float x = mod(floor(id / 6.), across);
  float y = floor(id / (6. * across));
  float u = x / (across - 1.0);
  float v = y / (across - 1.0);
  float ux = 2. * u - 1.;
  float vy = 2. * v - 1.;
  return vec2(ux, vy);
}

out vec4 v_color;
out vec4 v_position;
out vec4 v_normal;
void main() {
  float quadId = floor(vertexId / 6.0);
  vec2 scale = 0.1 + hash21(quadId + 1);
  float color = hash11(quadId + 10);
  float z = 20.0 * hash11(quadId + 3);
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  /*
  mat4 Model = mat4(rotY(DEG2RAD * (90 * hash11(quadId + 13) - 45.0) *
                         sin(iTime + 2 * PI * hash11(quadId + 14))));
  ;
  */
  mat4 Model = mat4(rotZ(DEG2RAD * 150 * iTime));
  mat3 Normal = transpose(inverse(mat3(Model)));
  vec4 vertex = Model * vec4(1.2 * quad(vertexId), z, 1.0);
  vec4 model = vec4(vec2(20.) * grid(25, vertexId), 0.0, 0.) + vertex;
  v_color.rgb = vec3(1.0, 1.0, 1.0);
  v_color.a = color;
  v_position = model;
  v_normal = normalize(vec4(Normal * vec3(0.0, 0.0, 1.0), 1.0));
  gl_Position = Projection * Camera * model;
}
#endif

#endif

// PASS 2: The UI
#ifdef GRIM_PASS_2
#define GRIM_OVERRIDE_MAIN
#ifdef GRIM_VERTEX

out vec4 v_color;
out vec4 v_position;
out vec4 v_normal;
void main() {
  float id = vertexId;
  float ar = iResolution.z;
  // Translate to the upper-left corner and shrink it down
  mat4 TS = transpose(vec3(-0.85, 0.85, 0.)) * mat4(scale(.1));
  vec3 vertex = arcball() * coordinate_frame_point(id);
  v_color = vec4(coordinate_frame_color(id), 1.0);
  v_position = vec4(vertex, 1.0);
  v_normal = vec4(0.0, 0.0, 1.0, 1.0);
  gl_Position = TS * v_position;
}
#endif
#endif

#if defined(GRIM_FRAGMENT) && !defined(GRIM_PASS_3)
#define GRIM_OVERRIDE_MAIN
in vec4 v_color;
in vec4 v_position;
in vec4 v_normal;

layout(location = 0) out vec4 gColor;
layout(location = 1) out vec4 gPosition;
layout(location = 2) out vec4 gNormal;
void main() {
  gColor = v_color;
  gPosition = v_position;
  gNormal = v_normal;
}
#endif

// PASS 3: SSAO
#ifdef GRIM_PASS_3
#ifdef GRIM_FRAGMENT

struct Light {
  vec3 Position;
  vec3 Color;
  float Linear;
  float Quadratic;
};

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  const int NR_LIGHTS = 3;
  Light lights[NR_LIGHTS];
  lights[0].Position = vec3(0.0, 0.0, 30.0);
  lights[0].Color = vec3(1.0, 0.1, 1.0);
  lights[0].Linear = 0.0001;
  lights[0].Quadratic = 0.00001;

  lights[1].Position = vec3(10.0, 0.0, 15.0);
  lights[1].Color = vec3(0.9, 0.9, 0.9);
  lights[1].Linear = 0.0001;
  lights[1].Quadratic = 0.0001;

  lights[2].Position = vec3(-10.0, 0.0, 20.0);
  lights[2].Color = vec3(0.9, 0.0, 0.0);
  lights[2].Linear = 0.001;
  lights[2].Quadratic = 0.01;
  // retrieve data from G-buffer
  vec3 FragPos = texture(gPosition, uv).rgb;
  vec3 Normal = texture(gNormal, uv).rgb;
  vec4 color = texture(gColor, uv);
  vec3 Diffuse = color.rgb;
  float Specular = color.a;

  // then calculate lighting as usual
  vec3 lighting = Diffuse * 0.01; // hard-coded ambient component
  mat4 C = camera() * mat4(arcball());
  vec3 viewPos = C[3].xyz;
  // vec3 viewPos = vec3(C[0][3], C[1][3], C[2][3]);
  // vec3 viewPos = vec3(C[0][3], C[1][3], C[2][3]);
  vec3 viewDir = normalize(viewPos - FragPos);
  for (int i = 0; i < NR_LIGHTS; ++i) {
    // diffuse
    vec3 lightDir = normalize(lights[i].Position - FragPos);
    vec3 diffuse = max(dot(Normal, lightDir), 0.0) * Diffuse * lights[i].Color;
    // specular
    vec3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(Normal, halfwayDir), 0.0), 16.0);
    vec3 specular = lights[i].Color * spec * Specular;
    // attenuation
    float dist = length(lights[i].Position - FragPos);
    float attenuation = 1.0 / (1.0 + lights[i].Linear * dist +
                               lights[i].Quadratic * dist * dist);
    diffuse *= attenuation;
    specular *= attenuation;
    lighting += diffuse + specular;
  }

  fragColor = vec4(lighting, 1.0);
}
#endif
#endif
