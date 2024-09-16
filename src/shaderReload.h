#ifndef SHADER_RELOAD_H
#define SHADER_RELOAD_H

#include "raylib.h"

// Function to load or reload the shader based on file modification time
void loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader* currentShader, float resolution[2]);

// Function to update shader values for time and mouse
void updateShaderValues(Shader* pShader, Vector2 mousePos, float totalTime);

// Uniform location variables for time and mouse
// extern int timeLoc;
// extern int mouseLoc;

#endif // SHADER_RELOAD_H
