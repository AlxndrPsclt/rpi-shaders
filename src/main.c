#include "raylib.h"
#include "audio.h"
#include "shader.h"
#include "textures.h"
#include "osc.h"  // Add this to include OSC server
#include <time.h>

#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_PI or other platforms
    #define GLSL_VERSION            100
#endif

int main(void) {
    const int screenWidth = 1920;
    const int screenHeight = 1080;
    InitWindow(screenWidth, screenHeight, "Shader + Audio Visualization + OSC");

    // Start OSC server
    startOscServer();  // Initialize the OSC server

    // FFT and Audio initialization
    initFFT();
    ma_device device;
    ma_encoder encoder;
    initAudio(&device, &encoder);

    // Shader and texture initialization
    Shader shader;
    time_t fragShaderFileModTime;
    const char *fragShaderFileName = "resources/shaders/glsl%i/myshader.glsl";

    shader = loadShaderWithReloading(TextFormat(fragShaderFileName, GLSL_VERSION), &fragShaderFileModTime);

    float resolution[2] = { (float)screenWidth, (float)screenHeight };
    Vector2 mousePos = { 0.0f, 0.0f };
    float totalTime = 0.0f;
    Texture2D audioTexture, messageTexture;
    int audioTextureLoc = GetShaderLocation(shader, "texture3");
    int messageTextureLoc = GetShaderLocation(shader, "texture4");

    // Uniform locations for different OSC paths
    int oscFloatLoc = GetShaderLocation(shader, "oscFloat");
    int oscIntLoc = GetShaderLocation(shader, "oscInt");
    int oscVec3Loc = GetShaderLocation(shader, "oscVec3");

    initAudioTexture(&audioTexture, shader, audioTextureLoc);
    initMessageTexture(&messageTexture, shader, messageTextureLoc);

    SetTargetFPS(60);
    while (!WindowShouldClose()) {
        totalTime += GetFrameTime();
        mousePos = GetMousePosition();

        // Get the OSC values from the OSC server
        float oscFloat = getOscFloat();
        int oscInt = getOscInt();
        float *oscVec3 = getOscVec3();

        // Update shader values and textures
        updateShaderValues(shader, resolution, &mousePos, &totalTime, &lowfreqs);
        
        // Pass the OSC values to the shader
        SetShaderValue(shader, oscFloatLoc, &oscFloat, SHADER_UNIFORM_FLOAT);  // Pass the float value
        SetShaderValue(shader, oscIntLoc, &oscInt, SHADER_UNIFORM_INT);  // Pass the int value
        SetShaderValue(shader, oscVec3Loc, oscVec3, SHADER_UNIFORM_VEC3);  // Pass the vec3 value
        

        UpdateTexture(audioTexture, fftInputFloat);
        UpdateTexture(messageTexture, messageFloats);

        // Rendering
        BeginDrawing();
            ClearBackground(RAYWHITE);
            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, BLACK);
            EndShaderMode();
        EndDrawing();
    }

    // Cleanup
    UnloadShader(shader);
    UnloadTexture(audioTexture);
    UnloadTexture(messageTexture);
    CloseWindow();
    cleanupAudio(&device, &encoder);

    return 0;
}

