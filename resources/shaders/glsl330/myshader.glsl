#version 330

precision mediump float;

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;

// Uniform inputs
uniform vec2 resolution;        // Viewport resolution (in pixels)
uniform float time;             // Total run time (in secods)
uniform sampler2D texture0;
uniform sampler2D myimage;



void main()
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;  // Normalize the screen coordinates

    vec4 prevColor = texture2D(myimage, uv);

    gl_FragColor = prevColor;
}
