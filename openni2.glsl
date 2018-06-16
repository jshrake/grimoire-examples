// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
[kinect2]
pipeline = "openni2src sourcetype=both ! videoconvert ! video/x-raw,format=RGBA ! appsink name=appsink"

[[pass]]
iChannel0 = "kinect2"
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 color_uv = 1.0 - fragCoord/iResolution.xy;
    vec2 depth_uv =  vec2(512.0/1920.0, 424.0/1080.0)* color_uv;
    vec3 color = texture(iChannel0, color_uv).rgb;
    vec3 depth = texture(iChannel0, depth_uv).aaa;
    fragColor = vec4(mix(color, depth, 0.5 + 0.5*sin(iTime)), 1.0);
}

