// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Based on https://pdfs.semanticscholar.org/presentation/1ee5/493e437ed1d80e679b372c8de77c2b332e2b.pdf
// The data comes volumetric data comes from http://schorsch.efi.fh-nuernberg.de/data/volume/, see the FAQ in the grimoire README for more information

/*
[volume]
texture3D = "resources/CT-Head.raw"
width     = 256
height    = 256
depth     = 113
format    = "rgu8"

[[pass]]
iChannel0 = "volume"
*/

mat4x4 rotX(float a) {
  float ca = cos(a);
  float sa = sin(a);
  return mat4x4(
    1.0, 0.0, 0.0, 0.0,
    0.0, ca, -sa, 0.0,
    0.0, sa, ca, 0.0,
    0.0, 0.0, 0.0, 1.0
  );
}

mat4x4 rotY(float a) {
  float ca = cos(a);
  float sa = sin(a);
  return mat4x4(
    ca, 0.0, sa, 0.0,
    0.0, 1.0, 0.0, 0.0,
    -sa, 0.0, ca, 0.0,
    0.0, 0.0, 0.0, 1.0
  );
}

mat4x4 rotZ(float a) {
  float ca = cos(a);
  float sa = sin(a);
  return mat4x4(
    ca, -sa, 0.0, 0.0,
    sa, ca, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
  );
}

mat4x4 rotXYZ(vec3 xyz) {
  return rotX(xyz.x) * rotY(xyz.y) * rotZ(xyz.z);
}

// From https://pdfs.semanticscholar.org/presentation/1ee5/493e437ed1d80e679b372c8de77c2b332e2b.pdf
bool IntersectBox(vec3 ro, vec3 rd, vec3 boxmin, vec3 boxmax, out float tnear, out float tfar) {
  // compute intersection of ray with all six bbox planes
  vec3 invR = 1.0 / rd;
  vec3 tbot = invR * (boxmin.xyz - ro);
  vec3 ttop = invR * (boxmax.xyz - ro);
  // re-order intersections to find smallest and largest on each axis
  vec3 tmin = min (ttop, tbot);
  vec3 tmax = max (ttop, tbot);
  // find the largest tmin and the smallest tmax
  vec2 t0 = max (tmin.xx, tmin.yz);
  tnear = max (t0.x, t0.y);
  t0 = min (tmax.xx, tmax.yz);
  tfar = min (t0.x, t0.y);
  // check for hit
  bool hit;
  if ((tnear > tfar))
  hit = false;
  else
  hit = true;
  return hit;
}

vec4 transfer(float val) {
  return vec4(val, 0.5*val, val, 1.0);
}

float sin01(float x) {
  return 0.5*(1.0 + sin(x));
}

float cos01(float x) {
  return 0.5*(1.0 + cos(x));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // phi, theta, radius
    iChannel0;
    vec2 uv = fragCoord / iResolution.xy - 0.5;
    uv.x *= iResolution.z;
    vec2 mouse = 2 * 3.14 * (iMouse.xy / iResolution.xy);
    vec3 ro = vec3(0.0, 0.0, -20.0);
    vec3 rd = normalize(vec3(uv, 0.0) - ro);
    mat4x4 rot = rotXYZ(vec3(-mouse.yx, 0.0));
    //float x = -0.5*3.14 + 0.0*sin(10.0*iTime);
    //float y = 0.1*iTime * 2 * 3.14;
    //mat4x4 rot = rotXYZ(vec3(x, y, 0.0));
    // rotate the cam eye and origin
    ro = (rot * vec4(ro, 1.0)).xyz;
    rd = (rot * vec4(rd, 0.0)).xyz;

    // calculate ray intersection with bounding box
    float tnear = 0.0;
    float tfar = 0.0;
    float steps = 1000;
    float base = 0.3;
    vec3 box = base * vec3(1.0);
    vec3 boxMin = -vec3(box);
    vec3 boxMax = vec3(box);
    bool hit = IntersectBox(ro, rd, boxMin, boxMax, tnear, tfar);
    if (!hit) {
      fragColor = vec4(0.0);
      return;
    }

    if (tnear < 0.0) tnear = 0;
    // calculate intersection points
    vec3 near = ro + rd*tnear;
    vec3 far = ro + rd*tfar;

    // march inside the texture, accumulating color from back to front
    vec4 c = vec4(0.0);
    for(float i=0.0; i<steps; i++) {
      vec3 P = mix(far, near, i / (steps - 1.0));
      vec3 coord = (P + box) / (2.0 * box);
      vec4 s = texture(iChannel0, coord);
      float a = s.r;
      c = a*s + (1.0 - a)*c;
    }
    c *= 20.0;
    fragColor = transfer(c.r);
}