// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[[pass]]
clear     = [0.0, 0.0, 0.0, 1.0]
blend     = {src = "one", dst = "one-minus-src-alpha" }
depth     = "less"
draw      = {mode = "points", count = 1000}
*/
#define GRIM_OVERRIDE_MAIN

#ifdef GRIM_VERTEX
#define vertexId gl_VertexID
#define vertexCount iVertexCount
#define resolution iResolution
#define time iTime

out vec4 v_color;

// from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
    c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    float down = floor(sqrt(vertexCount));
    float across = floor(vertexCount / down);
    float x = mod(vertexId, across);
    float y = floor(vertexId / across);
    float u = x / (across - 1.0);
    float v = y / (across - 1.0);

    float xoff = sin(time * 1.1 + 0.2  * y) * 0.1;
    float yoff = sin(time * 1.2 + 0.3  * x) * 0.2;

    float ux = 2. * u - 1. + xoff;
    float vy = 2. * v - 1. + yoff;

    vec2 xy = vec2(ux, vy) * 1.3;

    gl_Position = vec4(xy, 0.0, 1.0);

    float soff = sin(time * 1.4 + x * y * 0.02) * 15.;

    gl_PointSize = 10.0 + soff;
    gl_PointSize *= 20. / across;
    gl_PointSize *= resolution.x / 600.;

    float hue = u * .1 + sin(time * 1.5 + v * 20.0) * 0.05;
    float sat = 1.;
    float val = sin(time * 1.6 + v * u * 20.0) * 0.5 + 0.5; 

    v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
#endif

#ifdef GRIM_FRAGMENT
in vec4 v_color;
out vec4 fragColor;
void main() {
    fragColor = v_color;
}
#endif