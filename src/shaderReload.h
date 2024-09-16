#ifndef SHADER_RELOAD_H
#define SHADER_RELOAD_H

#include "raylib.h"
#include "osc.h"
#include "uthash.h"  // Use uthash for hash table

// Uniform value storage structure
typedef struct {
    char path[MAX_PATH_SIZE];  // Uniform name (key)
    float value;               // Last value set for the uniform
    UT_hash_handle hh;         // Hash table handle
} UniformCache;

// Declare the hash table globally
extern UniformCache *uniformCache;

// Function prototypes
void storeUniformValue(const char *path, float value);
void restoreUniformValues(Shader *pShader);
void loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader* pCurrentShader, float resolution[2]);
void updateShaderValues(Shader* pShader, Vector2 mousePos, float totalTime);

#endif // SHADER_RELOAD_H
