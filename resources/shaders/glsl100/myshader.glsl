#version 100
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;             // Total run time (in secods)
uniform vec2 resolution;        // Viewport resolution (in pixels)
// Uniforms to control zoom and pan
float zoom=1.5; // Controls the zoom level
float panX=0.0; // Controls horizontal panning
float panY=0.0; // Controls vertical panning
float iterations=10.0; // Number of iterations

uniform sampler2D texture3;

const float PI = 3.1415926535897932384626433;
const float DEFAULT_RANDOM_FROM_FLOAT_PARAM = 502000.0;
const vec2 DEFAULT_RANDOM_FROM_VEC2_PARAM = vec2(0.840,0.290);
const float MIC_AMPLIFICATION=10.0;


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



void main() {
    // Calculate the normalized coordinates (0 to 1 range)
//    float sampleValue = 0.1 + MIC_AMPLIFICATION*(texture2D(texture3, vec2(uv.x, 0.5)).r-0.5);
//    float soundEnergy = MIC_AMPLIFICATION*(
//        texture2D(texture3, vec2(0.01, 0.5)).r+
//        texture2D(texture3, vec2(0.1, 0.5)).r+
//        texture2D(texture3, vec2(0.2, 0.5)).r+
//        texture2D(texture3, vec2(0.3, 0.5)).r+
//        texture2D(texture3, vec2(0.4, 0.5)).r+
//        texture2D(texture3, vec2(0.5, 0.5)).r+
//        texture2D(texture3, vec2(0.6, 0.5)).r+
//        texture2D(texture3, vec2(0.7, 0.5)).r+
//        texture2D(texture3, vec2(0.8, 0.5)).r+
//        texture2D(texture3, vec2(0.9, 0.5)).r+
//        texture2D(texture3, vec2(0.11, 0.5)).r
//        );
//
//    soundEnergy=soundEnergy*0.21-11.4;
//    float lowSampleValue = MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.01, 0.5)).r-0.5);
//    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.03, 0.5)).r-0.5);
//    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.04, 0.5)).r-0.5);
//    lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.05, 0.5)).r-0.5);
//    //lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.15, 0.5)).r-0.5);
//    //lowSampleValue += MIC_AMPLIFICATION*(texture2D(texture3, vec2(0.2, 0.5)).r-0.5);
//    lowSampleValue *= lowSampleValue * lowSampleValue*20.0;
//    //float sampleValue = (texture2D(texture3, vec2(uv.x, 0.5)).r - 0.5)*20.0 + 0.5;  // Accessing the red channel which contains our sample data
//    float soundwaveValue=1.0-smoothstep(length(sampleValue), 0.15, 0.2);

    float zoomTime=sin(time)*zoom;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    //uv.xy *=(1.0+noise(time));
    uv.xy *= (1.0+noise(time)*uv.x);
    uv.y +=3.0*noise(time)*noise(uv.y)*noise(uv.y*10.0*cos(time*0.1));
    uv.y +=3.0*noise(time)*noise(uv.y)*noise(uv.x*30.0*cos(time*0.1));

    vec3 gridGradient = vec3(uv.x,uv.y,0.0);
    // Scale and translate coordinates according to zoom and pan
    float x = zoom*uv.y;
    float r = zoom*(0.5*uv.x+3.5);

    vec3 gridGradient2 = vec3(x,r,0.0);
    // Initial value for the logistic map
    float xn = x;
    bool inside = false;
    int iterFinal=1;

    // Iterate the logistic map
    for (int i = 1; i < int(iterations); i++) {
        xn = r*(1.0+0.01) * xn * (1.0 - xn);

        // If the value falls within the current pixel, set the pixel to white
        iterFinal=i;
        if (abs(xn -x) < 0.0775) {
            inside = true;
            break;
        }
    }
    //inside = true;

    // Set the color based on whether the point was inside the logistic map
    vec3 color = vec3(0.0);
    //if (inside) {
    color = vec3(1.0-exp(xn-x));
    //color = vec3(1.0-float(iterFinal)/iterations);
    color = vec3(1.0-float(iterFinal)/iterations);
    color*=rand(uv.y);
    color*=rand(uv.x*noise(uv.y*time));
    //} else {
        //color = vec3(0.0);
    //}
    //gl_FragColor = vec4(vec3(0.3*exp(color.x*uv.y*sin(time)), tan(color.y), tan(color.z)), 1.0);
    gl_FragColor = vec4(color*color*color*2.0*3.0, 1.0);
}

