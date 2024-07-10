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

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdTriangleIsosceles( in vec2 p, in vec2 q )
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
}

float drawCircle( in vec2 p, in vec2 c, in float r)
{
//vec2 pa = p-a, ba = b-a;
    float currentPoint = length( p - c );
    float circleLine = abs(currentPoint - r);
    //float cicleLine = smoothstep(0.45,0.5,);
    float value = 1.0-smoothstep(0.000,0.003, circleLine);
    return value;
}

float drawTriangle( in vec2 p, in vec2 c, in float r, in float d)
{
//vec2 pa = p-a, ba = b-a;
    float sdTri = sdEquilateralTriangle(p-c, r);
    float value = 1.0-float(d<abs(sdTri));
    //float value = smoothstep(0.000,0.003, min(0.05,sdTri));
    return value;
}

float drawIsoTriangle(in vec2 p, in vec2 c, in vec2 q, in float d)
{
//vec2 pa = p-a, ba = b-a;
    float sdTri = sdTriangleIsosceles(p-c, q);
    float value = 1.0-float(d<abs(sdTri));
    //float value = smoothstep(0.000,0.003, min(0.05,sdTri));
    return value;
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

    vec2 uv = gl_FragCoord.xy/resolution.x;
    //uv = rotate2d(PI/2.0)*uv;
    //uv+=vec2(1.0,1.0);

    vec3 color=vec3(0.0);

    //color+= triangleValue;


    float currentGlobalRotationAngle = sin(time)*PI;
    float circleRadius = 0.2;
    vec2 circleCenter = vec2(0.5, resolution.y/(2.0*resolution.x));
    vec2 centeredUv = uv-circleCenter;

    color += drawCircle(uv, circleCenter, circleRadius);

    vec2 trianglesOffset = vec2(0.0,circleRadius+0.04);

    vec2 uv1 = rotate2d(currentGlobalRotationAngle)*centeredUv-trianglesOffset;
    vec2 uv2 = rotate2d(currentGlobalRotationAngle+PI/2.0)*centeredUv-trianglesOffset;
    vec2 uv3 = rotate2d(currentGlobalRotationAngle+PI)*centeredUv-trianglesOffset;
    vec2 uv4 = rotate2d(currentGlobalRotationAngle+3.0*PI/2.0)*centeredUv-trianglesOffset;

    color+= drawTriangle(uv, circleCenter+vec2(0.0,0.24), 0.03, 0.0025);

    color+= drawTriangle(uv1, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uv2, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uv3, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uv4, vec2(0.0,0.0), 0.03, 0.0025);


    color+= drawIsoTriangle(uv, circleCenter+vec2(0.00,0.14), vec2(0.03,-0.1), 0.003);
    color+= drawIsoTriangle(uv, circleCenter-vec2(0.00,0.14), vec2(0.03,0.1), 0.003);

    //vec3 color=vec3(uv.x, uv.y, 0.0);
//color*=6.0*mod(time/2.0,1.0);
    //color*=step(0.6, fract(time));

    vec3 gridGradient = vec3(uv.x,uv.y,0.0);
    //color+=gridGradient;

    gl_FragColor = vec4(color, 1.0);
}
