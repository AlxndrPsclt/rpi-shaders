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

mat2 rotate2d(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat2(
        c, -s,
        s, c
    );
}

vec2 CENTER = vec2(0.5, 0.5);

void main()
{
    vec2 uv = gl_FragCoord.xy/resolution;
    uv -= vec2(CENTER);
    uv = rotate2d(2*PI*noise(bassMagnitude)*time/20.0)*uv;
    uv += vec2(CENTER);
    vec2 texCoord = gl_FragCoord.xy / textureSize; // Normalize to [0, 1]
                                                       //

    float sampleValue = texture(texture3, vec2((noise(time))*80.0*uv.x, 0.5)).r;  // Accessing the red channel which contains our sample data
    //uv -= vec2(sin(time)/2.0, sampleValue/2.0);
    float soundwaveValue=1.0-smoothstep(length(sampleValue*uv), 0.15, 0.2);
    vec3 color = vec3(sampleValue, 0.0, rand(sampleValue));

    gl_FragColor = vec4(30.0*bassMagnitude*bassMagnitude*color*soundwaveValue, 1.0);
}
