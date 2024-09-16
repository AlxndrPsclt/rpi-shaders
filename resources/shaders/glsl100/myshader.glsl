#version 100

precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform float F11;   // Float uniform for /osc/float
uniform float F12;   // Float uniform for /osc/float
uniform float F13;   // Float uniform for /osc/float
uniform float F14;   // Float uniform for /osc/float

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;  // Normalize the screen coordinates
    
    // Use oscFloat to adjust the color based on time
    //vec3 color = vec3(F11 * uv.x, F12 * uv.y, abs(sin(time * F13)));
    
    // Use oscInt to influence brightness (scaling factor)
    vec3 colorGrid = vec3(uv.x, uv.y, 0.0);
    vec3 color = vec3(F11*abs(cos(time/3.0)), F12, F13*abs(sin(time/0.5)));
    
    gl_FragColor = vec4(color, 1.0);
}

