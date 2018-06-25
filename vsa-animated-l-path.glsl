// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
// License
/*
[scene]
buffer = true

# ground
[[pass]]
#clear     = [0.6235, 0.7843, 0.7607, 1.0]
clear      = [0.545098, 0.509804, 0.521569, 1.0]
blend     = {src = "src-alpha",  dst= "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "triangles", count = 2}
buffer    = "scene"

# quads
[[pass]]
blend     = {src = "src-alpha",  dst= "one-minus-src-alpha" }
draw      = {mode = "triangles", count = 6000}
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

#include <grim.glsl>

#define PLANE_SIDE_LEN 10.0

// PASS 0: Ground plane
#ifdef GRIM_PASS_0
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
void main() {
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  gl_Position = Projection * Camera * transpose(vec3(0, -1, 0)) *
                mat4(rotX(0.5 * PI)) *
                vec4(0.5 * PLANE_SIDE_LEN * quad(vertexId), 0, 1);
  // v_color = vec4(139, 130, 133.0, 255.0) / 255.0;
  v_color = vec4(0.6235, 0.7843, 0.7607, 1.0);
}
#endif // GRIM_VERTEX

#ifdef GRIM_FRAGMENT
in vec4 v_color;
out vec4 fragColor;
void main() { fragColor = v_color; }
#endif // GRIM_FRAGMENT
#endif // GRIM_PASS_0

// PASS 1: The quads animating along the edges
#ifdef GRIM_PASS_1
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
out vec4 v_color;
void main() {
  float quadid = floor(vertexId / 6.0);
  vec3 A = 0.5 * PLANE_SIDE_LEN * vec3(-1.0, 0.0, -1.0);
  vec3 B = 0.5 * PLANE_SIDE_LEN * vec3(1.0, 0.0, 1.0);
  vec3 diff = B - A;
  vec3 C1 = A + vec3(1.0, 0.0, 0.0) * diff;
  vec3 C2 = B - vec3(1.0, 0.0, 0.0) * diff;
  vec3 C = mix(C1, C2, round(hash11(quadid + 3333.0)));
  float anim_len = 3.0 + 10.0 * hash11(quadid + 52);
  float offset = 5.0 * anim_len * hash11(quadid + 7.0);
  float maxt = anim_len + 5.0 * anim_len;
  float t = mod(iTime, anim_len + offset) - offset;
  float param = smoothstep(0.0, maxt, t);
  float corner_offset = 0.3 * hash11(quadid + 132.);
  float corner0 = 0.5 + corner_offset;
  float corner1 = 0.5 - corner_offset;
  vec3 P1 = mix(A, C, smoothstep(0.0, corner0 * anim_len, t));
  vec3 P2 = mix(C, B, smoothstep(corner1 * anim_len, anim_len, t));
  vec3 P = mix(P1, P2, smoothstep(0.0, anim_len, t)) +
           (2.0 * hash31(quadid + 23.) - 1.0) * vec3(1.0, 0.0, 1.0);

  float scale = 0.1 * (1.0 + hash11(quadid + 2.0));
  float s = mix(-1, 1, step(0.5, hash11(quadid + 70.0)));
  vec3 V = P + vec3(0.0, -0.95, 0.0) +
           s * rotY(iTime * hash11(quadid + 10.0)) *
               vec3(scale * quad(vertexId), 0).xzy;
  mat4 Projection = projection();
  mat4 Camera = camera() * mat4(arcball());
  gl_Position = Projection * Camera * vec4(V, 1);
  float cr = hash11(quadid + 32.0);
  vec3 c0 = vec3(227, 168, 164) / 255.0;
  vec3 c1 = vec3(241, 210, 205) / 255.0;
  vec3 c2 = vec3(240, 242, 218) / 255.0;
  vec3 c = mix(c0, c1, step(0.33, cr));
  c = mix(c, c2, step(0.66, cr));
  v_color = vec4(c, 1.0);
  v_color.a =
      0.8 * ((1.0 - step(0.5 * anim_len, t)) * smoothstep(-0.5, 0.0, t) +
             step(0.5 * anim_len, t) * smoothstep(anim_len, 0.9 * anim_len, t));
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
