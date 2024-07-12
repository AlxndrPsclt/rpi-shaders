#version 100

precision mediump float;

const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const vec2 DEFAULT_RANDOM_FROM_VEC2_PARAM = vec2(0.840,0.290);
const float MIC_AMPLIFICATION=10.0;

const vec3 lineColor=vec3(2.5,0.1,2.0);

uniform float lowfreqs;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform vec2 textureSize;    // The dimensions of the texture

const float BPM=129.0;
const float BPS = BPM/60.0;

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

float sdLine( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = dot(pa,ba)/dot(ba,ba);
    return length( pa - ba*h );
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

float drawSegment( in vec2 p, in vec2 a, in vec2 b )
{
    float lineSDF = sdSegment(p, a, b);
    float line = 1.0-smoothstep(0.002,0.0021,abs(lineSDF));
    return line;
}
float drawSegments( in vec2 p, in vec2 a, in vec2 b )
{
    float lineSDF;
    float line;
    for(float i = 1.0; i < 100.0; i += 1.0) {
      lineSDF = sdSegment(p, a+vec2(0.0,0.1), b+vec2(0.0,0.1));
      line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF));
    }
    return line;
}
float drawGrid( in vec2 p, in vec2 origin)
{
    float isPartOfTheGrid=0.0;
    //isPartOfTheGrid=abs(floor(p-origin))<0.1;
    isPartOfTheGrid = 1.0-smoothstep(fract(abs(p.y+origin.y)), 0.993, 1.0);
    isPartOfTheGrid+= 1.0-smoothstep(fract(abs(p.y+origin.y)), 0.0, 0.007);
    //isPartOfTheGrid+= fract(abs(p.x-origin.x));
    return isPartOfTheGrid;
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
// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;           // Texture coordinates (sampler2D)
varying vec4 fragColor;              // Tint color

// Uniform inputs
uniform vec2 resolution;        // Viewport resolution (in pixels)
uniform vec2 mouse;             // Mouse pixel xy coordinates
uniform float time;             // Total run time (in secods)


void main()
{
    float BEAT_VALUE = time * BPS;
    float BEAT_NUMBER = floor(BEAT_VALUE);
    float BEAT = fract(BEAT_VALUE);
    float BEAT2 = fract(BEAT_VALUE * 0.5);
    float BEAT4 = fract(BEAT_VALUE * 0.25);
    float BEAT8 = fract(BEAT_VALUE * 0.125);
    float BEAT16 = fract(BEAT_VALUE * 0.0625);
    float BEAT32 = fract(BEAT_VALUE * 0.03125);

    vec2 uv = gl_FragCoord.xy/resolution;
    //uv = rotate2d(PI/2.0)*uv;
    //uv+=vec2(1.0,1.0);

    vec3 color=vec3(0.0);
    //vec3 color=vec3(uv.x, uv.y, 0.0);
//color*=6.0*mod(time/2.0,1.0);
    //color*=step(0.6, fract(time));
    color+=vec3(0.4,0.2,3.6*noise(time/7.0))*drawSegment(uv.xy, vec2(noise(uv.y),0.3)*noise(time+4.0*uv.x), vec2(0.7*5.0+noise(noise(sin(time))), 0.3*5.0+noise(noise(time))));
    color+=2.0*noise(time)*vec3(0.6,0.0,0.6)*drawSegment(uv.xy, vec2(rand(uv.y*uv.x),0.7)*noise(time+4.0*uv.x), vec2(0.3, uv.x)*noise(noise(time)));
    color+=vec3(0.8*noise(time*uv.x),0.0,0.3)*drawSegment(uv.xy, vec2(0.8,rand(uv.y*uv.x))*noise(time+4.0*uv.y), vec2(0.8+noise(noise(time/7.0)), 0.9-noise(noise(time))));

    gl_FragColor = vec4(color, 1.0);
}
