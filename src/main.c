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

void printIntArray(int* pArray, int size) {
    printf("[");
    for (int i = 0; i < size; i++) {
        printf("%d", pArray[i]);  // Access each element
        if (i < size - 1) {
            printf(", ");
        }
    }
    printf("]\n");
}

int main(void) {
    const int screenWidth = 1920;
    const int screenHeight = 1080;
    float resolution[2] = { (float)screenWidth, (float)screenHeight };  // Define resolution first

    InitWindow(screenWidth, screenHeight, "Shader + Audio Visualization + OSC");

    initOSCQueue(QUEUE_SIZE);

    // Start OSC server
    startOscServer();  // Initialize the OSC server

    // FFT and Audio initialization
    initFFT();
    ma_device device;
    ma_encoder encoder;
    initAudio(&device, &encoder);

    // Shader and texture initialization
    Shader shader;
    Shader* pShader = &shader;

    time_t fragShaderFileModTime;
    const char *fragShaderFileName = "resources/shaders/glsl%i/myshader.glsl";

    loadShaderWithReloading(TextFormat(fragShaderFileName, GLSL_VERSION), &fragShaderFileModTime, pShader, resolution);

    int resolutionLoc = GetShaderLocation(shader, "resolution");

    // Set the resolution uniform (this is essential to reset after reloading)
    SetShaderValue(shader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);

    if (shader.id == 0) {
        printf("Failed to load shader: %s\n", fragShaderFileName);
    }

    Vector2 mousePos = { 0.0f, 0.0f };
    float totalTime = 0.0f;

//    int testTimeLoc = GetShaderLocation(shader, "timex");
//    printf("testTimeLoc main shaderLocation: %d\n", testTimeLoc);

    printIntArray(shader.locs, 10);
    //int audioTextureLoc = GetShaderLocation(shader, "texture3");
    //printf("audioTexture main shaderLocation: %i\n", audioTextureLoc);
    //int messageTextureLoc = GetShaderLocation(shader, "texture4");
    //printf("MessageTexture main shaderLocation: %i\n", messageTextureLoc);

    //initAudioTexture(&audioTexture, shader, audioTextureLoc);
    //initMessageTexture(&messageTexture, shader, messageTextureLoc);

    bool shaderAutoReloading = true;  // Auto-reload shader on file changes

    SetTargetFPS(60);
    int uniformLocation;
    while (!WindowShouldClose()) {

        // Shader auto-reloading logic
        if (shaderAutoReloading || IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
            loadShaderWithReloading(TextFormat(fragShaderFileName, GLSL_VERSION), &fragShaderFileModTime, pShader, resolution);
        }

        // Toggle auto-reloading with the 'A' key
        if (IsKeyPressed(KEY_A)) {
            shaderAutoReloading = !shaderAutoReloading;
        }

        // Update time and mouse position
        totalTime += GetFrameTime();
        mousePos = GetMousePosition();

        updateShaderValues(pShader, mousePos, totalTime);

        //UpdateTexture(audioTexture, fftInputFloat);
        //UpdateTexture(messageTexture, messageFloats);

        // Dequeue OSC messages and update shader uniforms
        while (ck_ring_size(&oscQueue.ring) > 0) {
            OSCMessage oscMessage = dequeueOSCMessage();
            uniformLocation = GetShaderLocation(shader, oscMessage.path);
            SetShaderValue(shader, uniformLocation, &oscMessage.value, SHADER_UNIFORM_FLOAT);
        }

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
    //UnloadTexture(audioTexture);
    //UnloadTexture(messageTexture);
    CloseWindow();
    cleanupAudio(&device, &encoder);

    return 0;
}

