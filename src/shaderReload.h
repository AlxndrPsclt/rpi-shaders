#ifndef SHADER_RELOAD_H
#define SHADER_RELOAD_H

#include "raylib.h"

// Function to load or reload the shader and reset the necessary uniforms
Shader loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader currentShader, int *uniformLocations, float resolution[2]);

// Function to update all shader values at once
void updateShaderValues(Shader shader, int *uniformLocations, float oscFloat, int oscInt, float *oscVec3, Vector2 mousePos, float totalTime);

#endif // SHADER_RELOAD_H
