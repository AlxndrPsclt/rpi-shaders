#include "shaderReload.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uthash.h"

// Declare global uniform location variables for time and mouse
int timeLoc = -1;
int mouseLoc = -1;

// Global hash table for storing uniform values
UniformCache *uniformCache = NULL;

// Store the last value of the uniform in the hash table
void storeUniformValue(const char *path, float value) {
    UniformCache *entry;

    // Check if the uniform is already in the cache
    HASH_FIND_STR(uniformCache, path, entry);

    if (entry == NULL) {
        // Uniform not found, add it to the cache
        entry = (UniformCache *)malloc(sizeof(UniformCache));
        strncpy(entry->path, path, MAX_PATH_SIZE);
        entry->value = value;
        HASH_ADD_STR(uniformCache, path, entry);
    } else {
        // Update the existing value
        entry->value = value;
    }
}

// Restore uniform values on shader reload
void restoreUniformValues(Shader *pShader) {
    UniformCache *entry, *tmp;

    // Iterate over the cache and set uniform values in the shader
    HASH_ITER(hh, uniformCache, entry, tmp) {
        int uniformLocation = GetShaderLocation(*pShader, entry->path);
        SetShaderValue(*pShader, uniformLocation, &entry->value, SHADER_UNIFORM_FLOAT);
        printf("Restored uniform %s with value %f\n", entry->path, entry->value);
    }
}

// Function to load or reload the shader and restore uniform values
void loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader* pCurrentShader, float resolution[2]) {
    long currentFragShaderModTime = GetFileModTime(fragShaderFileName);
    Shader updatedShader;

    if (currentFragShaderModTime != *fragShaderFileModTime) {
        // Reload the shader if the file has been modified
        printf("Loading or reloading shader\n");
        updatedShader = LoadShader(0, fragShaderFileName);

        if (updatedShader.id != 0) {
            UnloadShader(*pCurrentShader);  // Unload the old shader

            // Set the resolution uniform
            int resolutionLoc = GetShaderLocation(updatedShader, "resolution");
            SetShaderValue(updatedShader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);

            // Restore all previously set uniform values
            restoreUniformValues(&updatedShader);
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
