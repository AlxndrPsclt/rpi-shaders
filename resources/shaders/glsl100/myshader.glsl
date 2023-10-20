#version 100

precision mediump float;

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

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;           // Texture coordinates (sampler2D)
varying vec4 fragColor;              // Tint color

// Uniform inputs
uniform vec2 resolution;        // Viewport resolution (in pixels)
uniform vec2 mouse;             // Mouse pixel xy coordinates
uniform float time;             // Total run time (in secods)


void main()
{
    vec2 uv = 5.0*gl_FragCoord.xy/resolution;
    vec2 position = vec2(mouse.x, resolution.y - mouse.y);

    //float lineSDF = sdSegment( uv, vec2(-1.0,sin(0.5*PI*time)/2.0), vec2(1.0,-cos(0.5*PI*time)/2.0));
    float lineSDF = sdSegment( uv, vec2(0.0,0.7), vec2(1.0,0.7));
    float line = 1.0-smoothstep(0.002,0.0021,abs(lineSDF));

    //float grid = drawGrid(10.0*(uv+noise(fract(uv.x*uv.x))*noise(noise(fract(uv.x)*20.0)*6.0*uv.y)), vec2(0.0,time));
    float grid = drawGrid(uv+vec2(0.0, noise(sin(time/5.0))*10.0*noise(time/17.77)*noise(noise(time/6.0)*uv.x*noise(uv.x*uv.y)*0.5*floor(uv.y)*noise(50.0*uv.y))), vec2(0.0,noise(5.0*uv.y)*noise(3.0*uv.x)*cos(5.0*uv.x*noise(time))));

    // Draw circle layer
    //vec3 color = grid*vec3(noise(uv.y)*noise(time), 0.1, noise(uv.y));
    vec3 color = 3.0*grid*vec3(3.0*noise(uv.y)*noise(uv.x)*noise(time*sin(time)), 0.01, noise(2.0*uv.y));

    gl_FragColor = vec4(1.0*color, 1.0);
}
