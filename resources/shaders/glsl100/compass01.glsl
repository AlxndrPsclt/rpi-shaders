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
uniform sampler2D texture4;
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
//varying vec4 fragColor;              // Tint color

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
    //

    float messageValue = texture2D(texture4, vec2(uv.x, 0.5)).r;

    float sampleValue = 0.1 + MIC_AMPLIFICATION*(texture2D(texture3, vec2(uv.x, 0.5)).r-0.5);
    float soundEnergy = MIC_AMPLIFICATION*(
        texture2D(texture3, vec2(0.01, 0.5)).r+
        texture2D(texture3, vec2(0.1, 0.5)).r+
        texture2D(texture3, vec2(0.2, 0.5)).r+
        texture2D(texture3, vec2(0.3, 0.5)).r+
        texture2D(texture3, vec2(0.4, 0.5)).r+
        texture2D(texture3, vec2(0.5, 0.5)).r+
        texture2D(texture3, vec2(0.6, 0.5)).r+
        texture2D(texture3, vec2(0.7, 0.5)).r+
        texture2D(texture3, vec2(0.8, 0.5)).r+
        texture2D(texture3, vec2(0.9, 0.5)).r+
        texture2D(texture3, vec2(0.11, 0.5)).r
        );
    soundEnergy=soundEnergy*0.21-11.4;
    float lowSampleValue = MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.01, 0.5)).r-0.5);
    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.03, 0.5)).r-0.5);
    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.04, 0.5)).r-0.5);
    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.05, 0.5)).r-0.5);
    //lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.15, 0.5)).r-0.5);
    //lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.2, 0.5)).r-0.5);
    lowSampleValue *= lowSampleValue * lowSampleValue*20.0;
    //float sampleValue = (texture2D(texture3, vec2(uv.x, 0.5)).r - 0.5)*20.0 + 0.5;  // Accessing the red channel which contains our sample data
    float soundwaveValue=1.0-smoothstep(length(sampleValue), 0.15, 0.2);
    vec3 color=vec3(0.0);

    //color+= triangleValue;


    float currentGlobalRotationAngle = sin(time*0.5)*PI;
    float circleRadius = 0.2;
    vec2 circleCenter = vec2(0.5, resolution.y/(2.0*resolution.x));
    vec2 centeredUv = uv-circleCenter;

    float angle = acos(dot(centeredUv, vec2(0.0,1.0)));
    float noiseOffsetAngle = noise(5.0*noise(angle*uv.x)+time/5.0)/7.0;
    vec2 stableUv=uv;
    uv+=noiseOffsetAngle;
    centeredUv = uv-circleCenter+noise(soundEnergy/time);
    float peakFactorSin=3.0*smoothstep(0.9,0.99,sin(uv.x+time))+0.3*noise(3.0*uv.y+time);
    float peakFactorCos=3.0*smoothstep(0.9,0.99,cos(uv.x+time))+0.3*noise(3.0*uv.y+time);
    color += drawCircle(uv, circleCenter, (0.5+sin(time*0.5)*1.3)*circleRadius*(1.0+noise(time*uv.y)*0.0));
    color += drawCircle(uv, circleCenter, (0.5+sin(time*0.5)*1.0)*circleRadius*(1.0+noise(time*uv.x)*0.01));
    color += drawCircle(uv, circleCenter, (0.5+sin(time*0.5)*0.75)*circleRadius*(1.0+noise(time*uv.x)*0.00));
    color += drawCircle(uv, circleCenter, (0.5+sin(time*0.5)*0.5*noise(time))*circleRadius*(1.0+noise(time*uv.x)*0.00));
    
    vec2 uvMagnetic = rotate2d(currentGlobalRotationAngle+noise(soundEnergy))*centeredUv;
    color += drawCircle(uv, circleCenter-noise(sampleValue*sqrt(uv.x*uv.x+uv.y*uv.y)), (0.5+sin(time*0.5)*1.3)*circleRadius*(1.0+noise(time*uv.y)*0.0));
    color += drawCircle(uv, circleCenter+noise(sampleValue*sqrt(uv.x*uv.x+uv.y*uv.y)), (0.5+sin(time*0.5)*1.6)*circleRadius*(1.0+noise(time*uv.x)*0.01));

    vec2 trianglesOffset = vec2(0.0,(circleRadius+0.04)*soundEnergy*3.0+circleRadius*0.5);

    vec2 uvN = rotate2d(currentGlobalRotationAngle+noise(time*0.3)/4.0)*centeredUv-trianglesOffset;
    vec2 uvE = rotate2d(currentGlobalRotationAngle+noise(time*0.3+noise(time*0.3))+PI/2.0)*centeredUv-trianglesOffset;
    vec2 uvS = rotate2d(currentGlobalRotationAngle+noise(time*0.3+noise(time*time*0.1))/4.0+PI)*centeredUv-trianglesOffset;
    vec2 uvW = rotate2d(currentGlobalRotationAngle+noise(time*0.3+1.77*noise(rand(3.0)*time))/4.0+3.0*PI/2.0)*centeredUv-trianglesOffset;

    //color+= drawTriangle(uv, circleCenter+vec2(0.0,0.24), 0.03, 0.0025);

    color+= drawTriangle(uvN, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uvE, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uvS, vec2(0.0,0.0), 0.03, 0.0025);
    color+= drawTriangle(uvW, vec2(0.0,0.0), 0.03, 0.0025);



    vec2 isoTriangleOffset = vec2(0.0,0.11);
    vec2 uvArrowN = rotate2d(3.0*lowSampleValue-currentGlobalRotationAngle*(1.0+noise(time)))*centeredUv-isoTriangleOffset;
    vec2 uvArrowS = rotate2d(2.0*lowSampleValue-currentGlobalRotationAngle*(1.0+noise(noise(time)))+PI)*centeredUv-isoTriangleOffset;
    color+= vec3(drawIsoTriangle(uvArrowN, vec2(0.0,0.0), vec2(0.03,-0.1), 0.003),0.0,0.0);
    color+= drawIsoTriangle(uvArrowS, vec2(0.0,0.0), vec2(0.03,-0.1), 0.003);

    //vec3 color=vec3(uv.x, uv.y, 0.0);
//color*=6.0*mod(time/2.0,1.0);
    //color*=step(0.6, fract(time));

    vec3 gridGradient = vec3(uv.x,uv.y,0.0);
    //color+=gridGradient;
    //color=texture2D(texture3, vec2(0.5, 0.0)).xyz;

    vec3 sound = vec3(lowSampleValue);

    //color+=vec3(float(abs(uv.y-9.0*sampleValue*sampleValue)<0.004));
    //color+=vec3(float(abs(stableUv.y-soundEnergy)<0.004));

    vec3 shades = vec3(0.9,0.1,0.2*noise(time*uv.y));
    //gl_FragColor = vec4(color*soundEnergy*soundEnergy*7.0, 1.0);
    float peakFactor=3.0*smoothstep(0.99,0.999,cos(time*0.9));
    vec3 flash = shades*peakFactor*soundEnergy;
    color=color*7.0+flash;
    //color=vec3(tan(color.x),sin(color.y),cos(color.z));
    gl_FragColor = vec4(messageValue+color, 1.0);
    //gl_FragColor = vec4(color*3.0*vec3(0.9*noise(time*uv.x), 0.3, 0.4*noise(uv.y)), 1.0);
}
