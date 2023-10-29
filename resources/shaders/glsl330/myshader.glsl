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

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}


vec2 CENTER = vec2(0.5, 0.5);

void main()
{
    vec2 uv = vec2(0.0,0.0);
    uv.x = (gl_FragCoord.x-resolution.x/2.0)/min(resolution.x,resolution.y);
    uv.y = (gl_FragCoord.y-resolution.y/2.0)/min(resolution.x,resolution.y);
    //uv *= GRID_RESOLUTION;
    float ctime = time/5.0;

    //float half_bar = 1./u_tex0Resolution.x;
    //float bassMagnitude = texture2D(u_tex0, vec2((uv.x+0.5)/100.0, 0.5) ).r;

    float lineSDF = sdSegment( uv, vec2(-1.0,sin(0.01*PI*ctime)/2.0), vec2(1.0,sin(0.1*PI*ctime)/2.0));
    //float line = lineSDF * max(-triangleSDF, 0.0);
    float line = 1.0-smoothstep(0.002,0.0021,abs(lineSDF));

    float lineSDF1 = sdSegment( uv+vec2(0.0,0.15), vec2(-1.0,sin((0.05+noise(bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.06+noise(6.0*bassMagnitude)/1000.0)*PI*ctime)/2.0));
    float lineSDF2 = sdSegment( uv+vec2(0.0,0.3), vec2(-1.0,sin((0.05+noise(2.0*bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.09+noise(5.0*bassMagnitude)/1000.0)*PI*ctime)/2.0));
    float lineSDF3 = sdSegment( uv+vec2(0.0,0.45), vec2(-1.0,sin((0.07+noise(3.0*bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.08+noise(4.0*bassMagnitude)/1000.0)*PI*ctime)/2.0));
    float lineSDF4 = sdSegment( uv-vec2(0.0,0.15), vec2(-1.0,sin((0.08+noise(4.0*bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.07+noise(3.0*bassMagnitude)/1000.0)*PI*ctime)/2.0));
    float lineSDF5 = sdSegment( uv-vec2(0.0,0.3), vec2(-1.0,sin((0.09+noise(5.0 * bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.05+noise(2.0*bassMagnitude)/1000.0)*PI*ctime)/2.0));
    float lineSDF6 = sdSegment( uv-vec2(0.0,0.45), vec2(-1.0,sin((0.06+noise(6.0*bassMagnitude)/1000.0)*PI*ctime)/2.0), vec2(1.0,sin((0.05+noise(bassMagnitude)/1000.0)*PI*ctime)/2.0));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF1));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF2));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF3));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF4));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF5));
    line += 1.0-smoothstep(0.002,0.0021,abs(lineSDF6));




    float scanLineSDF = sdSegment( uv, vec2(sin(0.08*PI*ctime)/2.0,-1.0), vec2(sin(0.06*PI*ctime)/2.0, 1.0));
    float scanline = 1.0-smoothstep(0.002,0.0021,abs(scanLineSDF));
    
    uv = rotate2d(noise(bassMagnitude)*PI*ctime)*uv;


    float sampleValue = texture(texture3, vec2((noise(ctime))*80.0*uv.x, 0.5)).r;  // Accessing the red channel which contains our sample data
    //uv -= vec2(sin(ctime)/2.0, sampleValue/2.0);
    float soundwaveValue=1.0-smoothstep(length(sampleValue*uv), 0.15, 0.2);
    //vec3 color = vec3(sampleValue, 0.0, rand(sampleValue));


    vec3 lineColored=line*vec3(4.4,0.2,0.7);
    vec3 scanLineColored=scanline*vec3(0.2,0.7,3.0);
    vec3 color = vec3(lineColored+scanLineColored);
    //color = vec3(bassMagnitude);
    //fragColor = vec4(color, 1.0);




    gl_FragColor = vec4(2.0*color, 1.0);
}
