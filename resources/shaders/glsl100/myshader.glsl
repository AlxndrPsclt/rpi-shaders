#version 100

precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform float oscFloat;   // Float uniform for /osc/float
uniform float oscInt;     // Int uniform for /osc/int (note: GLSL 100 lacks int uniforms, so we use float)
uniform vec3 oscVec3;     // Vec3 uniform for /osc/vec3

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;  // Normalize the screen coordinates
    
    // Use oscFloat to adjust the color based on time
    vec3 color = vec3(oscVec3.r * uv.x, oscVec3.g * uv.y, abs(sin(time * oscFloat)));
    
    // Use oscInt to influence brightness (scaling factor)
    color *= mod(oscInt, 5.0) + 1.0;  // Modulate by oscInt value

    vec3 colorGrid = vec3(uv.x, uv.y, 0.0);
    
    gl_FragColor = vec4(colorGrid*oscFloat, 1.0);
}

