#include "shaderReload.h"
#include <stdio.h>
#include <time.h>

// Function to load or reload the shader based on file modification time
Shader loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader currentShader, int *uniformLocations, float resolution[2]) {
    long currentFragShaderModTime = GetFileModTime(fragShaderFileName);

    if (currentFragShaderModTime != *fragShaderFileModTime) {
        // Reload the shader if the file has been modified
        Shader updatedShader = LoadShader(0, fragShaderFileName);

        if (updatedShader.id != 0) {
            UnloadShader(currentShader);  // Unload the old shader
            currentShader = updatedShader;

            // Reset uniform locations
            uniformLocations[0] = GetShaderLocation(currentShader, "oscFloat");
            uniformLocations[1] = GetShaderLocation(currentShader, "oscInt");
            uniformLocations[2] = GetShaderLocation(currentShader, "oscVec3");
            uniformLocations[3] = GetShaderLocation(currentShader, "texture3");
            uniformLocations[4] = GetShaderLocation(currentShader, "texture4");
            uniformLocations[5] = GetShaderLocation(currentShader, "mouse");
            uniformLocations[6] = GetShaderLocation(currentShader, "time");
            int resolutionLoc = GetShaderLocation(currentShader, "resolution");

            // Set the resolution uniform (this is essential to reset after reloading)
            SetShaderValue(currentShader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);
        }

        // Update the modification time
        *fragShaderFileModTime = currentFragShaderModTime;
    }

    return currentShader;
}

// Function to update all shader values at once
void updateShaderValues(Shader shader, int *uniformLocations, float oscFloat, int oscInt, float *oscVec3, Vector2 mousePos, float totalTime) {
    // Update float uniform (OSC float)
    SetShaderValue(shader, uniformLocations[0], &oscFloat, SHADER_UNIFORM_FLOAT);

    // Update int uniform (OSC int)
    SetShaderValue(shader, uniformLocations[1], &oscInt, SHADER_UNIFORM_INT);

    // Update vec3 uniform (OSC vec3)
    SetShaderValue(shader, uniformLocations[2], oscVec3, SHADER_UNIFORM_VEC3);

    // Update texture uniforms
    SetShaderValue(shader, uniformLocations[3], NULL, SHADER_UNIFORM_SAMPLER2D); // Texture3
    SetShaderValue(shader, uniformLocations[4], NULL, SHADER_UNIFORM_SAMPLER2D); // Texture4

    // Update mouse position uniform
    SetShaderValue(shader, uniformLocations[5], &mousePos, SHADER_UNIFORM_VEC2);

    // Update time uniform
    SetShaderValue(shader, uniformLocations[6], &totalTime, SHADER_UNIFORM_FLOAT);
}

