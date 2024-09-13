#ifndef SHADER_H
#define SHADER_H

#include "raylib.h"
#include <time.h>

Shader loadShaderWithReloading(const char* fragShaderFileName, time_t* fragShaderFileModTime);
void updateShaderValues(Shader shader, float* resolution, Vector2* mousePos, float* totalTime, float* lowfreqs);

#endif // SHADER_H

