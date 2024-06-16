#version 100

precision mediump float;

const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const vec2 DEFAULT_RANDOM_FROM_VEC2_PARAM = vec2(0.840,0.290);
const float MIC_AMPLIFICATION=10.0;

const vec3 lineColor=vec3(0.5,0.1,2.0);

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
    //uv = rotate2d(PI*noise(lowfreqs)/5.0)*uv;

    vec2 position = vec2(mouse.x, resolution.y - mouse.y);

    float sampleValue = 0.5 + MIC_AMPLIFICATION*(texture2D(texture3, vec2(uv.x, 0.5)).r-0.5);
    //float sampleValue = (texture2D(texture3, vec2(uv.x, 0.5)).r - 0.5)*20.0 + 0.5;  // Accessing the red channel which contains our sample data
    float soundwaveValue=1.0-smoothstep(length(sampleValue*uv), 0.15, 0.2);
                                                                                   //
    //float lineSDF = sdSegment( uv, vec2(-1.0,sin(0.5*PI*time)/2.0), vec2(1.0,-cos(0.5*PI*time)/2.0));
    //float lineSDF = sdSegment( uv, vec2(0.0,0.7), vec2(1.0,0.7));
    //float line = 1.0-smoothstep(0.002,0.0021,abs(lineSDF));
    float nline=0.0;

    //float grid = drawGrid(10.0*(uv+noise(fract(uv.x*uv.x))*noise(noise(fract(uv.x)*20.0)*6.0*uv.y)), vec2(0.0,time));
    //float grid = drawGrid(uv+vec2(0.0, noise(sin(time/5.0))*10.0*noise(time/17.77)*noise(noise(time/6.0)*uv.x*noise(uv.x*uv.y)*0.5*floor(uv.y)*noise(50.0*uv.y))), vec2(0.0,noise(5.0*uv.y)*noise(3.0*uv.x)*cos(5.0*uv.x*noise(time))));


    float smoothLowfreqs = smoothstep(0.1,2.5,lowfreqs);
    //float smoothLowfreqs2 = smoothstep(1.0,5.0,lowfreqs*(cos(time)+1.0)/2.0);



    //float lineSDF1 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,sin((0.05+noise(bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.06+noise(6.0*bassMagnitude)/1000.0)*PI*time)/2.0));
    //float lineSDF2 = sdSegment( uv+vec2(0.0,0.3), vec2(-1.0,sin((0.05+noise(2.0*bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.09+noise(5.0*bassMagnitude)/1000.0)*PI*time)/2.0));
    //float lineSDF3 = sdSegment( uv+vec2(0.0,0.45), vec2(-1.0,sin((0.07+noise(3.0*bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.08+noise(4.0*bassMagnitude)/1000.0)*PI*time)/2.0));
    //float lineSDF4 = sdSegment( uv-vec2(0.0,0.15), vec2(-1.0,sin((0.08+noise(4.0*bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.07+noise(3.0*bassMagnitude)/1000.0)*PI*time)/2.0));
    //float lineSDF5 = sdSegment( uv-vec2(0.0,0.3), vec2(-1.0,sin((0.09+noise(5.0 * bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.05+noise(2.0*bassMagnitude)/1000.0)*PI*time)/2.0));
    //float lineSDF6 = sdSegment( uv-vec2(0.0,0.45), vec2(-1.0,sin((0.06+noise(6.0*bassMagnitude)/1000.0)*PI*time)/2.0), vec2(1.0,sin((0.05+noise(bassMagnitude)/1000.0)*PI*time)/2.0));
    //
    float fastime = time*15.0;

    float lineSDF;

    vec2 onde;
    //vec2 onde = vec2(0.0, sin(uv.x*10.0*PI-fastime)/12.5)*smoothLowfreqs2;
    //vec2 onde = vec2(0.0, (2.0*noise(3.0*uv.x+fastime)+3.0*sin(uv.x)/uv.x)/12.5)*smoothLowfreqs2;

    float possibleToShowWave;
    float smoothLowfreqs2;
    float ctime;

    for(float i = 0.0; i < 7.0; ++i) {
      possibleToShowWave = (smoothstep(0.6,0.9,noise(7.333*(i+1.0)*time))+0.05);
      smoothLowfreqs2 = smoothstep(1.0,5.0,lowfreqs*possibleToShowWave);

      onde = vec2(0.0, cos(noise(i*time)*uv.x*3.33*PI-fract(fastime))*sin(uv.x*10.0*i*PI-fastime)/12.5)*smoothLowfreqs2;
      ctime = time*0.1+smoothLowfreqs2;
      lineSDF = sdSegment(uv + onde, vec2(0.0,abs(sin((i+ctime)/6.0))), vec2(1.0,abs(sin((i+ctime)/6.0))));
      //lineSDF = sdSegment( uv, vec2(-1.0,abs(cos(lowfreqs)+sin((i+ctime)/6.0))), vec2(1.0,noise(uv.y)+abs(sin(lowfreqs)+sin((i+ctime)/6.0))));
      nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF));
    }
    //float lineSDF2 = sdSegment( uv, vec2(-1.0,fract((0.6+time)/6.0)), vec2(1.0,fract((0.6+time)/6.0)));
//    float lineSDF3 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,fract(time/6.0)), vec2(1.0,fract(time/6.0)));
//    float lineSDF4 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,fract(time/6.0)), vec2(1.0,fract(time/6.0)));
//    float lineSDF5 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,fract(time/6.0)), vec2(1.0,fract(time/6.0)));
//    float lineSDF6 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,fract(time/6.0)), vec2(1.0,fract(time/6.0)));

    //nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF1));
    //nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF2));
//    nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF3));
//    nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF4));
//    nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF5));
//    nline += 1.0-smoothstep(0.002,0.0021,abs(lineSDF6));

    float scanLineSDF = sdSegment( uv/5.0, vec2(sin(0.08*PI*time/10.0)/2.0,-1.0), vec2(sin(0.06*PI*time/10.1)/2.0, 1.0));
    float scanline = 1.0-smoothstep(0.0001,0.00011*(1.0+smoothLowfreqs2),abs(scanLineSDF));



    //vec3 color = 3.0*grid*vec3(3.0*noise(uv.y)*noise(uv.x)*noise(time*sin(time)), 0.01, noise(2.0*uv.y));
    vec3 color=vec3(0.0);

    vec3 scanLineColored=scanline*vec3(0.2,0.7,3.0);

    color+=scanLineColored;
    //color+=nline*vec3(0.0,0.07,5.0);
    color+=nline*vec3(2.6,0.4,0.0); // GREAT yellow cyberpunk color;  2.0*color in gl_FragColor
    //color+=nline*vec3(2.6,0.4,0.0); // GREAT yellow cyberpunk color;  2.0*color in gl_FragColor
    //color+=nline*vec3(1.6,0.1,2.0)*vec3(noise(noise(uv.x)),noise(noise(uv.y)),noise(time));
    //color+=soundwaveValue;
    //color+=grid;

    //color*=lowfreqs;

    //vec3 sound = vec3(sampleValue);

    //gl_FragColor = vec4(4.0*color*BEAT4, 1.0);
    gl_FragColor = vec4(3.0*color, 1.0);
}
