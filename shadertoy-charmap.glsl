// Original source: https://www.shadertoy.com/view/ldSBzd
/*
[font]
image = "resources/font.png"

[[pass]]
iChannel0 = "font"
*/

/*
 * Click on a char to get its ascii code, then include it into your shader with:
 *
 *     fragColor += texture(iChannel0, (fract(uv/s) + vec2(i,15-i/16))/16.).x;
 *
 * where i is the char code, s is the scale of the char relatively to
 * the screen (1.0 or vec2(1.0) for full screen) and uv is the normalized
 * fragment coordinates (= fragCoord.xy / iResolution.xy).
 *
 * (Don't forget to add the character texture as Channel0)
 *
 */

int idot(ivec2 a, ivec2 b) { return a.x * b.x + a.y * b.y; }
int index(vec2 uv) { return idot(ivec2(uv * 16.), ivec2(1, 16)); }
vec2 fromIndex(int i) { return vec2(i, i / 16) / 16.; }

/*
 * If you tend to index differently, change those two functions.
 * Make sure to also adapt the texture access in your own shader.
 *
 */
int displayIndex(vec2 uv) {
  // option 1: from bottom-left
  // (change vec2(i,15-i/16) into vec2(i,i/16) if you use this index)
  // return index(uv);

  // option2: from top-left (ascii order)
  return int(uv.x * 16.) + int((1. - uv.y) * 16.) * 16;
}

vec2 toWinUv(vec2 uv) {
  return (uv - vec2(0., 1. / 16.)) * vec2(1., 17. / 16.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 mouse = iMouse.xy / iResolution.xy;
  vec2 wuv = toWinUv(uv);
  vec2 wmouse = toWinUv(mouse);

  fragColor = texture(iChannel0, wuv);

  int i = index(wmouse);

  if (index(wuv) == i) {
    fragColor = 1. - fragColor;
  }

  if (uv.y < .0625) {
    if (length(iMouse) == 0.) {
      vec2 s = vec2(0.5, 1.);
      i = int[](179, 156, 153, 147, 155, 221, 157, 149, 80)[int(uv / s * 16.)];
      fragColor =
          vec4(texture(iChannel0, fract(uv / s * 16.) / 16. + fromIndex(i)).x);
    } else {
      if (uv.x < .0625) {
        fragColor = vec4(.7, .1, .7, 1.) *
                    texture(iChannel0, fract(uv * 16.) / 16. + fromIndex(i)).x;
      } else if (uv.x < .0625 * 4.) {
        i = displayIndex(max(wmouse, vec2(0., .0625)));
        int d = int(pow(10., ceil(3. - uv.x * 16.)) + .5);
        i = i / d % 10;
        i += 192;
        fragColor =
            vec4(texture(iChannel0, fract(uv * 16.) / 16. + fromIndex(i)).x);
      } else {
        fragColor *= 0.;
      }
    }
  }
}
