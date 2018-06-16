// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[depth]
pipeline = "freenect2src sourcetype=0 ! appsink name=appsink"

[[pass]]
iChannel0 = "depth"
*/

float map(vec3 p, float depth);
vec3 calcNormal(vec3 p, float depth);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 ro = vec3(0, 0, -1);
    vec2 q = (fragCoord.xy - .5 * iResolution.xy ) / iResolution.xy;
    vec3 rd = normalize(vec3(q, 0.) - ro);
    float h, t = 1.;
    vec2 uv = 1.0 - fragCoord / iResolution.xy;
    float depth = texture(iChannel0, uv).r / 700.0;
    if (depth < 0.1) {
        depth = 7.0;
    }
    for (int i = 0; i < 256; i++) {
        h = map(ro + rd * t, depth);
        t += h;
        if (h < 0.01) break;
    }

    if (h < 0.01 ) {
        vec3 p = ro + rd * t;
        vec3 normal = calcNormal(p, depth);
        vec3 light = vec3(0, 1, -0.5 + 4.0 * (0.5 + 0.5 * sin(iTime)));

        // Calculate diffuse lighting by taking the dot product of
        // the light direction (light-p) and the normal.
        float dif = clamp(dot(normal, normalize(light - p)), 0., 1.);

        // Multiply by light intensity (5) and divide by the square
        // of the distance to the light.
        dif *= 8.0 / dot(light - p, light - p);
        fragColor = vec4(0.3*dif, 0.2, dif, 1);
    } else {
        fragColor = vec4(1, 0, 0, 1);
    }
}

float map(vec3 p, float depth) {
    float sint = 0.5 + 0.5 * sin(iTime);
    float cost = 0.5 + 0.5 * cos(iTime);
    float d =   distance (depth, p.z);
    d = min(d,  distance(p, vec3(0.5 * cos(iTime), 0.2, 0.2)) - 0.05);
    d = min(d,  distance(p, vec3(-1.0, -0.2 + 0.7 * sint, 6.0)) - 0.7);
    return d;
}

vec3 calcNormal(in vec3 p, float depth) {
    vec2 e = vec2(1.0, -1.0) * 0.000005;
    return normalize(
        e.xyy * map(p + e.xyy, depth) +
        e.yyx * map(p + e.yyx, depth) +
        e.yxy * map(p + e.yxy, depth) +
        e.xxx * map(p + e.xxx, depth));
}
