#include "shaderReload.h"
#include <stdio.h>
#include <time.h>

// Declare global uniform location variables for time and mouse
int timeLoc = -1;
int mouseLoc = -1;

// Function to load or reload the shader based on file modification time
void loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader* pCurrentShader, float resolution[2]) {
    long currentFragShaderModTime = GetFileModTime(fragShaderFileName);
    Shader updatedShader;

    if (currentFragShaderModTime != *fragShaderFileModTime) {
        // Reload the shader if the file has been modified
        printf("Loading or reloading shader\n");
        updatedShader = LoadShader(0, fragShaderFileName);
        printf("ShaderR updatedShader pointer: %p\n", &updatedShader);

        if (updatedShader.id != 0) {
            printf("ShaderR currentShader pointer before unloading: %p\n", pCurrentShader);
            UnloadShader(*pCurrentShader);  // Unload the old shader
            printf("ShaderR currentShader pointer after unloading: %p\n", pCurrentShader);

            int F11 = GetShaderLocation(updatedShader, "F11");
            float someValue = 0.10f;
            SetShaderValue(updatedShader, F11, &someValue, SHADER_UNIFORM_FLOAT);
            // Cache the locations of time, mouse, and resolution uniforms
//            timeLoc = GetShaderLocation(updatedShader, "time");
//            printf("ShaderR timeLoc shaderLocation: %i\n", timeLoc);
//            mouseLoc = GetShaderLocation(updatedShader, "mouse");
//            printf("ShaderR MouseLoc  shaderLocation: %i\n", mouseLoc);
        }

        // Update the modification time
        *fragShaderFileModTime = currentFragShaderModTime;
        *pCurrentShader = updatedShader;
    }
}

// Function to update shader values for time and mouse
void updateShaderValues(Shader* pShader, Vector2 mousePos, float totalTime) {
    // Update mouse position uniform
    mouseLoc = GetShaderLocation(*pShader, "mouse");
    SetShaderValue(*pShader, mouseLoc, &mousePos, SHADER_UNIFORM_VEC2);

    // Update time uniform
    timeLoc = GetShaderLocation(*pShader, "time");
    SetShaderValue(*pShader, timeLoc, &totalTime, SHADER_UNIFORM_FLOAT);
}
