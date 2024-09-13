#include "shader.h"
#include "rlgl.h"
#include <stdio.h>

Shader loadShaderWithReloading(const char* fragShaderFileName, time_t* fragShaderFileModTime) {
    Shader shader = LoadShader(0, fragShaderFileName);
    *fragShaderFileModTime = GetFileModTime(fragShaderFileName);
    return shader;
}

void updateShaderValues(Shader shader, float* resolution, Vector2* mousePos, float* totalTime, float* lowfreqs) {
    int resolutionLoc = GetShaderLocation(shader, "resolution");
    int mouseLoc = GetShaderLocation(shader, "mouse");
    int timeLoc = GetShaderLocation(shader, "time");
    int lowfreqsLoc = GetShaderLocation(shader, "lowfreqs");

    SetShaderValue(shader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, mouseLoc, mousePos, SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, timeLoc, totalTime, SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, lowfreqsLoc, lowfreqs, SHADER_UNIFORM_FLOAT);
}

