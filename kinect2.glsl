// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[kinect2]
pipeline = "freenect2src sourcetype=3 ! videoconvert ! video/x-raw,format=RGBA ! appsink name=appsink"

[[pass]]
iChannel0 = {resource = "kinect2", filter = "linear" }
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 color_uv = 1.0 - fragCoord/iResolution.xy;
    vec2 depth_uv =vec2(512.0/1920.0, 424.0/1080.0) * color_uv;
    vec3 color = texture(iChannel0, color_uv).rgb;
    vec3 depth = texture(iChannel0, depth_uv).aaa;
    fragColor = vec4(1.0-mix(color, depth, 1), 1.0);
}

