#ifndef SHADER_RELOAD_H
#define SHADER_RELOAD_H

#include "raylib.h"
#include "osc.h"
#include "uthash.h"  // Use uthash for hash table

#define MAX_VALUES 4  // Maximum number of float values (up to vec4)

typedef struct {
    char path[MAX_PATH_SIZE];    // Path (minus the '/')
    float values[MAX_VALUES];    // Array to store 1-4 floats (e.g., vec4)
    int value_count;             // Number of values (1 for float, 2 for vec2, etc.)
    UT_hash_handle hh;           // UTHash handle for the hash table
} UniformCache;


// Declare the hash table globally
extern UniformCache *uniformCache;

// Function prototypes
void storeUniformValue(const char *path, const float *values, int value_count);
void restoreUniformValues(Shader *pShader);
void loadShaderWithReloading(const char *fragShaderFileName, long *fragShaderFileModTime, Shader* pCurrentShader, float resolution[2]);
void updateShaderValues(Shader* pShader, Vector2 mousePos, float totalTime);

#endif // SHADER_RELOAD_H
