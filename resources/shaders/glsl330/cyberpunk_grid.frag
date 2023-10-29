#version 330
//#define BUFFER
#ifdef GL_ES
precision mediump float;
#endif

#include "lib/utils.glsl"
#include "lib/shapes.glsl"
#include "lib/shapingFunctions.glsl"
#include "lib/uniformsOSC.glsl"

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec2 u_frame;
uniform float u_time;

uniform sampler2D u_doubleBuffer0;

float GRID_RESOLUTION=20.0;

uniform sampler2D   u_tex0;
uniform vec2        u_tex0Resolution;
//uniform sampler2D u_tex0;
//uniform vec2 u_tex0Resolution;


float BPM=124.0;
float BPS = BPM/60.0;
float BEAT_VALUE = u_time * BPS;
float BEAT_NUMBER = floor(BEAT_VALUE);
float BEAT = fract(BEAT_VALUE);
float BEAT2 = fract(BEAT_VALUE * 0.5);
float BEAT4 = fract(BEAT_VALUE * 0.25);
float BEAT8 = fract(BEAT_VALUE * 0.125);
float BEAT16 = fract(BEAT_VALUE * 0.0625);
float BEAT32 = fract(BEAT_VALUE * 0.03125);
//float beat = fract(

//uniform sampler2D u_tex0;
//uniform vec2 u_tex0Resolution;

out vec4 fragColor;


//---------------------------------------------------------------------------

void main()
{
    //vec3 color = vec3(abs(sin(BEAT4)),0.001,abs(sin(BEAT_NUMBER)));

    //vec2 uv = (gl_FragCoord.xy-u_resolution.y/2.0)/min(u_resolution.x,u_resolution.y);
    vec2 uv = vec2(0.0,0.0);
    uv.x = (gl_FragCoord.x-u_resolution.x/2.0)/min(u_resolution.x,u_resolution.y);
    uv.y = (gl_FragCoord.y-u_resolution.y/2.0)/min(u_resolution.x,u_resolution.y);
    //uv *= GRID_RESOLUTION;

    float half_bar = 1./u_tex0Resolution.x;
    float fft = texture2D(u_tex0, vec2((uv.x+0.5)/100.0, 0.5) ).r;

    float lineSDF = sdSegment( uv, vec2(-1.0,sin(0.01*PI*u_time)/2.0), vec2(1.0,sin(0.1*PI*u_time)/2.0));
    //float line = lineSDF * max(-triangleSDF, 0.0);
    float line = 1.0-smoothstep(0.002,0.0021,abs(lineSDF));

    float lineSDF1 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,sin((0.05+noise(fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.06+noise(6.0*fft)/1000.0)*PI*u_time)/2.0));
    float lineSDF2 = sdSegment( uv+vec2(0.0,0.3), vec2(-1.0,sin((0.05+noise(2.0*fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.09+noise(5.0*fft)/1000.0)*PI*u_time)/2.0));
    float lineSDF3 = sdSegment( uv+vec2(0.0,0.45), vec2(-1.0,sin((0.07+noise(3.0*fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.08+noise(4.0*fft)/1000.0)*PI*u_time)/2.0));
    float lineSDF4 = sdSegment( uv-vec2(0.0,0.15), vec2(-1.0,sin((0.08+noise(4.0*fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.07+noise(3.0*fft)/1000.0)*PI*u_time)/2.0));
    float lineSDF5 = sdSegment( uv-vec2(0.0,0.3), vec2(-1.0,sin((0.09+noise(5.0 * fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.05+noise(2.0*fft)/1000.0)*PI*u_time)/2.0));
    float lineSDF6 = sdSegment( uv-vec2(0.0,0.45), vec2(-1.0,sin((0.06+noise(6.0*fft)/1000.0)*PI*u_time)/2.0), vec2(1.0,sin((0.05+noise(fft)/1000.0)*PI*u_time)/2.0));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF1));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF2));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF3));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF4));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF5));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF6));




    float scanLineSDF = sdSegment( uv, vec2(sin(0.08*PI*u_time)/2.0,-1.0), vec2(sin(0.06*PI*u_time)/2.0, 1.0));
    float scanline = 1.0-smoothstep(0.002,0.0021,abs(scanLineSDF));
    
    uv = rotate2d(noise(fft)*PI*u_time)*uv;

    //uv= vec2(uv.x*(1.0+rand(rand(uv.x+uv.y)+BEAT_NUMBER)), uv.y*(1.0+rand(rand(uv.y/uv.x)+BEAT_NUMBER)));
    //
    //float r=noiseFromVec2(5.0*uv);
    //float r4=r*r*r*r;
    //float r8=r*r*r*r;
    //uv = uv*(vec2(1.0,1.0)+r8/1.0);

    float triangleSDF = sdEquilateralTriangle(uv,0.3);
    float triangle = smoothstep(0.004, 0.00041, abs(triangleSDF));

//    uv = rotate2d(0.5*PI*noise(BEAT_NUMBER))*uv;
//    float triangle2 = smoothstep(0.004, 0.00041, abs(sdEquilateralTriangle(uv,0.4)));
//    uv = rotate2d(0.5*PI*noise(uv.x*BEAT_NUMBER))*uv;
//    float triangle3 = smoothstep(0.004, 0.00041, abs(sdEquilateralTriangle(uv,0.5)));

    //vec2 st = vec2(0.0,0.0);
    //st.x = (gl_FragCoord.x)/min(u_resolution.x,u_resolution.y);
    //st.y = (gl_FragCoord.y)/min(u_resolution.x,u_resolution.y);
    ////vec3 color = vec3(0.01,0.01,0.01);
    //vec3 color = vec3(step(0.5, rand(floor(uv.y)/floor(uv.x))));
    //color=color;
    //vec3 video = texture2D(u_tex0,vec2(1.0-uvUnit.x, uvUnit.y)).rgb;
    //video = vec3(video.r+video.g+video.b)/3.0;
    //color = video;

#ifdef DOUBLE_BUFFER_0
    //vec3 previousColor = texture2D(u_doubleBuffer0, st).rgb;
    //color += vec3(0.0,0.0,0.4);
    //float r=abs(randBin(BEAT_NUMBER));
#else
    //vec3 previousColor = texture2D(u_doubleBuffer0, st).rgb;
    //color=previousColor;
    //color = texture2D(u_doubleBuffer0, uv).rgb;
#endif
    //vec3 color = vec3(triangle+triangle2+triangle3);
    vec3 triangleColored=triangle*vec3(5.0,0.5,0.5);
    vec3 lineColored=line*vec3(0.4,0.2,5.0);
    vec3 scanLineColored=scanline*vec3(2.0,0.1,2.0);
    vec3 color = vec3(lineColored+scanLineColored);
    //color = vec3(fft);
    fragColor = vec4(color, 1.0);
}

    //color = pow(color, vec3(1.0));
