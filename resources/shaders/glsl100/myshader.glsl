#version 100

precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform float F11;   // Float uniform for /osc/float
uniform float F12;   // Float uniform for /osc/float
uniform float F13;   // Float uniform for /osc/float
uniform float F14;   // Float uniform for /osc/float
uniform sampler2D prevFrame;

const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;

float randomFromFloat(float seed, float param) {
  return fract(sin(seed) * param);
}

float randomFF(float seed) {
  return randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;  // Normalize the screen coordinates
    
    vec4 prevColor = texture2D(prevFrame, uv);
    // Use oscFloat to adjust the color based on time
    //vec3 color = vec3(F11 * uv.x, F12 * uv.y, abs(sin(time * F13)));
    //
    float point = step(0.984,randomFF(randomFF(floor(100.0*uv.x))+randomFF(floor(100.0*uv.y))*floor(time)));
    
    // Use oscInt to influence brightness (scaling factor)
    vec3 colorGrid = vec3(uv.x, uv.y, 0.0);
    vec3 color = vec3(F11, F12, F13);
    
    gl_FragColor = vec4(2.0*prevColor.xyz +color+point, 1.0);
}

