#include "raylib.h"
#include "audio.h"
#include "textures.h"
#include "osc.h"
#include "shaderReload.h"  // Include shader reloading and update function
#include <time.h>

#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_PI or other platforms
    #define GLSL_VERSION            100
#endif

int main(void) {
    const int screenWidth = 1920;
    const int screenHeight = 1080;
    float resolution[2] = { (float)screenWidth, (float)screenHeight };  // Define resolution first

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
    int uniformLocations[7];  // Array to store uniform locations (oscFloat, oscInt, oscVec3, texture3, texture4, mouse, time)
    shader = loadShaderWithReloading(TextFormat(fragShaderFileName, GLSL_VERSION), &fragShaderFileModTime, shader, uniformLocations, resolution);

    Vector2 mousePos = { 0.0f, 0.0f };
    float totalTime = 0.0f;
    Texture2D audioTexture, messageTexture;

    initAudioTexture(&audioTexture, shader, uniformLocations[3]);
    initMessageTexture(&messageTexture, shader, uniformLocations[4]);

    bool shaderAutoReloading = true;  // Auto-reload shader on file changes

    SetTargetFPS(60);
    while (!WindowShouldClose()) {

        // Shader auto-reloading logic
        if (shaderAutoReloading || IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
            shader = loadShaderWithReloading(TextFormat(fragShaderFileName, GLSL_VERSION), &fragShaderFileModTime, shader, uniformLocations, resolution);
        }

        // Toggle auto-reloading with the 'A' key
        if (IsKeyPressed(KEY_A)) {
            shaderAutoReloading = !shaderAutoReloading;
        }

        // Update the uniform and texture values
        // Get the OSC values from the OSC server
        float oscFloat = getOscFloat();
        int oscInt = getOscInt();
        float *oscVec3 = getOscVec3();
        // Update time and mouse position
        totalTime += GetFrameTime();
        mousePos = GetMousePosition();

        updateShaderValues(shader, uniformLocations, oscFloat, oscInt, oscVec3, mousePos, totalTime);

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

