// Created by Justin Shrake - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// USE_PLAYBIN3=1 RUST_LOG=info GST_DEBUG=3 grimoire video.glsl

/*
[video]
video = "https://upload.wikimedia.org/wikipedia/commons/1/18/The_Earth_in_4k.webm"

[[pass]]
iChannel0 = "video"
*/
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 texCoord = fragCoord / iResolution.xy;
  texCoord.y = 1.0 - texCoord.y;
  fragColor = texture(iChannel0, texCoord);
}
