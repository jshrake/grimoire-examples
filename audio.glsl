// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Original source: https://www.shadertoy.com/view/Xds3Rr

// See also:
//
// Input - Keyboard    : https://www.shadertoy.com/view/lsXGzf
// Input - Microphone  : https://www.shadertoy.com/view/llSGDh
// Input - Mouse       : https://www.shadertoy.com/view/Mss3zH
// Input - Sound       : https://www.shadertoy.com/view/Xds3Rr
// Input - SoundCloud  : https://www.shadertoy.com/view/MsdGzn
// Input - Time        : https://www.shadertoy.com/view/lsXGz8
// Input - TimeDelta   : https://www.shadertoy.com/view/lsKGWV
// Inout - 3D Texture  : https://www.shadertoy.com/view/4llcR4

/*
[music]
audio = "resources/sin.wav"

[[pass]]
iChannel0 = "music"
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  // create pixel coordinates
	vec2 uv = fragCoord.xy / iResolution.xy;

	// first texture row is frequency data
	float fft  = texture(iChannel0, vec2(uv.x,0.25)).x;

  // second texture row is the sound wave
	float wave = texture(iChannel0, vec2(uv.x,0.75)).x;

	// convert frequency to colors
	vec3 col = vec3(1.0)*fft;

  // add wave form on top
	col += 1.0 -  smoothstep( 0.0, 0.01, abs(wave - uv.y) );

  col = pow( col, vec3(1.0,0.5,2.0) );

	// output final color
	fragColor = vec4(col,1.0);
}
