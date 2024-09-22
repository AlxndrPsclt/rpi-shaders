#version 100

precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform float F11;   // Float uniform for /osc/float
uniform float F12;   // Float uniform for /osc/float
uniform float F13;   // Float uniform for /osc/float
uniform float F14;   // Float uniform for /osc/float
uniform float F15;   // Float uniform for /osc/float
uniform float F16;   // Float uniform for /osc/float
uniform float F17;   // Float uniform for /osc/float
uniform float F18;   // Float uniform for /osc/float
uniform float F19;   // Float uniform for /osc/float
uniform sampler2D prevFrame;

const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;

float randomFromFloat(float seed, float param) {
  return fract(sin(seed) * param);
}

float randomFF(float seed) {
  return randomFromFloat(seed, DEFAULT_RANDOM_FROM_FLOAT_PARAM);
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



void main() {
  vec2 uv = (gl_FragCoord.xy / resolution.x);  // Normalize the screen coordinates
                                               //vec2 uvtex = (gl_FragCoord.xy - vec2(F14,F15) / resolution.xy);  // Normalize the screen coordinates
                                               //uv=fract(10.0*uv);

                                               //float dispX = sin((F15*F15-0.5)*PI)/4.0+0.00*smoothstep(0.95,0.99, noise(uv.x*sin(time)));
  float dispX = sin((F15*F15-0.5)*PI)/4.0+0.25;
  float dispY = sin((F16*F16-0.5)*PI)/4.0+0.25;
  vec4 prevColor = texture2D(prevFrame, uv-vec2(dispX,dispY));
  // Use oscFloat to adjust the color based on time
  //vec3 color = vec3(F11 * uv.x, F12 * uv.y, abs(sin(time * F13)));
  //float point = step(0.984,randomFF(randomFF(floor(15.0*(1.0+3.0*F17)*uv.x))+randomFF(floor(15.0*(1.0+3.0*F18)*uv.y))*floor(time)));

  vec2 circleCenter = vec2(0.5, resolution.y/(2.0*resolution.x));
  vec2 centeredUv = uv-circleCenter;
  vec2 rotatedUv = rotate2d(2.0*PI*F18)*centeredUv;
  vec2 cell= floor(15.0*rotatedUv);
  vec2 incellCoord= fract(15.0*rotatedUv);
  vec2 displayCell=smoothstep(0.6*F17,0.7,sin(incellCoord));

  float intensite = length(prevColor);
  float point = step(0.5+F19/2.0,displayCell.x*displayCell.y*randomFF(randomFF(cell.x*intensite)+randomFF(cell.x*intensite)*floor(time)));
    
    // Use oscInt to influence brightness (scaling factor)
    vec3 colorGrid = vec3(uv.x, uv.y, 0.0);
    vec3 color = vec3(F11, F12, F13);
    
    gl_FragColor = vec4(1.0*(0.9+F14/10.0)*prevColor.xyz +color*point, 1.0);
}

