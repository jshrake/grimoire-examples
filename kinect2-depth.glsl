// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[depth]
pipeline = "freenect2src sourcetype=0 ! appsink name=appsink"

[[pass]]
iChannel0 = "depth"
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = 1.0 - fragCoord/iResolution.xy;
    float depth = texture(iChannel0, uv).r;
    fragColor = vec4(1.0-vec3(depth/4000.0), 1.0);
}

