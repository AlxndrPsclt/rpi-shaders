#version 330

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec4 fragColor;              // Tint color

// Uniform inputs
uniform vec2 resolution;        // Viewport resolution (in pixels)
uniform float time;             // Total run time (in secods)
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform vec2 textureSize;    // The dimensions of the texture
uniform float bassMagnitude;


const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const vec2 DEFAULT_RANDOM_FROM_VEC2_PARAM = vec2(0.840,0.290);

float randomFromFloat(float seed, float param) {
  return fract(sin(seed) * param);
}
float rand(float seed) {
  return randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
}
float noise(float seed) {
  float i = floor(seed);  // integer
  float f = fract(seed);
  return mix(rand(i), rand(i + 1.0), smoothstep(0.,1.,f));
}

void main()
{
    vec2 uv = gl_FragCoord.xy/resolution;
    vec2 texCoord = gl_FragCoord.xy / textureSize; // Normalize to [0, 1]
                                                       //

    float sampleValue = texture(texture3, vec2(uv.x, 0.5)).r;  // Accessing the red channel which contains our sample data
    vec3 color = vec3(0.8, 0.0, 0.7);

    gl_FragColor = vec4(bassMagnitude*color, 1.0);
}
