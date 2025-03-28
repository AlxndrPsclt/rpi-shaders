#version 100

precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform float zeroctl_F11;   // Float uniform for /osc/float
uniform float zeroctl_F12;   // Float uniform for /osc/float
uniform float zeroctl_F13;   // Float uniform for /osc/float
uniform float zeroctl_F14;   // Float uniform for /osc/float
uniform float zeroctl_F15;   // Float uniform for /osc/float
uniform float zeroctl_F16;   // Float uniform for /osc/float
uniform float zeroctl_F17;   // Float uniform for /osc/float
uniform float zeroctl_F18;   // Float uniform for /osc/float
uniform float zeroctl_F19;   // Float uniform for /osc/float
uniform float zeroctl_F21;   // Float uniform for /osc/float
uniform vec3 accelerometer;   // Float uniform for /osc/float
uniform sampler2D prevFrame;

const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const float NB_CELLULES = 100.0;

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


float courbeExp(float x) {
  return (1.0-abs(x-1.0)*abs(x-1.0)*abs(x-1.0));
}

void main() {
    float F11=zeroctl_F11;
    float F12=zeroctl_F12;
    float F13=zeroctl_F13;
    float F14=zeroctl_F14;
    float F15=zeroctl_F15;
    float F16=zeroctl_F16;
    float F17=zeroctl_F17;
    float F18=zeroctl_F18;
    float F19=zeroctl_F19;
    float F21=zeroctl_F21;

    vec2 uv = (gl_FragCoord.xy / resolution.xy);  // Normalize the screen coordinates
    uv+= accelerometer.xy/10.0;
    vec2 uvScaled =(uv-vec2(0.5, 0.5));
                                                 
    //vec2 uvtex = (gl_FragCoord.xy - vec2(F14,F15) / resolution.xy);  // Normalize the screen coordinates
    vec2 cell= floor(NB_CELLULES*uvScaled);
    vec2 uvScaledCell =(uv-(cell+0.5))*F17*1.0;
    vec2 cellCentered= floor(NB_CELLULES*uvScaledCell);
    
    float dispX = F15*F15*F15*F15;
    float dispY = F16*F16*F16*F16;
    vec4 prevColor = texture2D(prevFrame, uvScaled-vec2(dispX,dispY));
    // Use oscFloat to adjust the color based on time
    //vec3 color = vec3(F11 * uv.x, F12 * uv.y, abs(sin(time * F13)));


    vec2 incellCoord= fract(15.0*uv);
    ///vec2 displayCell=smoothstep(0.6,0.7,sin(incellCoord));

    float saturation = 0.0;
    vec3 voisins = vec3(0.0);
    for (float i = 0.0; i < 4.0; i += 1.0) {
      for (float j = 0.0; j < 4.0; j += 1.0) {
        voisins += texture2D(prevFrame, vec2(0.125+0.25*i,0.125+0.25*j)).rgb;
      }
    }
    voisins /= 16.0;
    saturation = length(voisins);

    float cs=1.0/NB_CELLULES;
    vec4 prevColorN = texture2D(prevFrame, uv+vec2(0.0,cs));
    vec4 prevColorNW = texture2D(prevFrame, uv+vec2(-cs,cs));
    vec4 prevColorNE= texture2D(prevFrame, uv+vec2(cs,cs));
    vec4 prevColorS = texture2D(prevFrame, uv+vec2(0.0,-cs));
    vec4 prevColorSW = texture2D(prevFrame, uv+vec2(-cs,-cs));
    vec4 prevColorSE = texture2D(prevFrame, uv+vec2(cs,-cs));
    vec4 prevColorW = texture2D(prevFrame, uv+vec2(-cs, 0.0));
    vec4 prevColorE = texture2D(prevFrame, uv+vec2(cs, 0.0));
    
    float point = step(courbeExp(F19),randomFF(randomFF(cell.x)+randomFF(cell.y)*floor(time)));
    vec4 pointVoisinEN = mix(prevColorE,prevColorN,0.5);
    vec4 pointVoisinWS = mix(prevColorW,prevColorS,0.5);
    vec4 pointVoisinWN = mix(prevColorW,prevColorN,0.5);
    vec4 pointVoisinES = mix(prevColorE,prevColorS,0.5);
    //float point = step(courbeExp(F19),randomFF(randomFF(floor(100.0*(1.0+3.0*F17)*uv.x))+randomFF(floor(100.0*(1.0+3.0*F18)*uv.y))*floor(time)));
    //float point = step(courbeExp(F19),randomFF(randomFF(floor(100.0*(1.0+3.0*F17)*uv.x))+randomFF(floor(100.0*(1.0+3.0*F18)*uv.y))*floor(time)));

    float composanteR = (prevColorE.r + prevColorS.r + prevColorSE.r + prevColorSW.r)/4.0;
    float composanteG = (prevColorN.g + prevColorNE.g + prevColorE.g + prevColorSW.g)/4.0;
    float composanteB = (prevColorNW.b + prevColorNE.b + prevColorE.b + prevColorS.b)/4.0;

    vec4 pointBinaire = vec4(composanteR, composanteG, composanteB, 1.0);
    
    // Use oscInt to influence brightness (scaling factor)
    vec3 colorGrid = vec3(uv.x, uv.y, 0.0);
    vec3 color = vec3(F11, F12, F13);
    
    vec4 finalColor = vec4((1.0+F14/10.0)*prevColor.xyz +color*point, 1.0)+0.06*noise(time)*(pointVoisinEN+pointVoisinWS+pointVoisinWN+pointVoisinES);
    finalColor= vec4(step(0.1,length(finalColor.rgb))*finalColor.rgb, 1.0);
    float sstepSaturation =smoothstep(1.5,1.74,saturation);
    float stepSaturation =step(1.3,saturation);


//G vR ->R
//B vG ->G
//R vB ->B
//
//G vG ->B
//B vB ->R
//R vR ->G

    vec3 normalizedV = normalize(finalColor.rgb);
    // Diagonal direction of the cube
    vec3 diagonal = normalize(vec3(1.0, 1.0, 1.0));

    // Calculate the dot product between normalizedV and diagonal
    float alignment = dot(normalizedV, diagonal);

    //

    vec3 finalColor3 =(1.0-sstepSaturation)*finalColor.rgb- 2.0*(courbeExp(alignment))*pointBinaire.rgb;

    normalizedV = normalize(finalColor3);
    alignment = dot(normalizedV, diagonal);
    float point2 = step(courbeExp(F19),randomFF(randomFF(3.0*cellCentered.x*fract(uv.x))+randomFF(3.0*cellCentered.y*fract(uv.y))*floor(time)));

    finalColor3 -= (courbeExp(alignment))*point2*vec3(0.3*randomFF(uv.x*sin(time)), 0.1*randomFF(uv.y*cos(time)),0.7*randomFF(uv.y*tan(time)));

    gl_FragColor = vec4(finalColor3, 1.0);
}
