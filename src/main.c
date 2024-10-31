#include "raylib.h"
#include "audio.h"
#include "textures.h"
#include "osc.h"
#include "utils.h"
#include "shaderReload.h"  // Include shader reloading and update function

#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_PI or other platforms
    #define GLSL_VERSION            100
#endif

int main(void) {
    SetTraceLogLevel(LOG_DEBUG);
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


    if (shader.id == 0) {
        printf("Failed to load shader: %s\n", fragShaderFileName);
    }

    int prevFrameLoc = GetShaderLocation(shader, "prevFrame");
    printf("prevFrameLoc = %d\n", prevFrameLoc);

    RenderTexture2D prevFrame = LoadRenderTexture(resolution[0], resolution[1]);
    RenderTexture2D currentFrame = LoadRenderTexture(resolution[0], resolution[1]);

    Vector2 mousePos = { 0.0f, 0.0f };
    float totalTime = 0.0f;

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
            char* oscMessage_path = replace_slash_with_underscore(oscMessage.path);

            uniformLocation = GetShaderLocation(shader, oscMessage_path);

            // Apply based on the number of arguments
            switch (oscMessage.value_count) {
                case 1:  // Single float
                    SetShaderValue(shader, uniformLocation, &oscMessage.values[0], SHADER_UNIFORM_FLOAT);
                    break;
                case 2:  // vec2
                    SetShaderValue(shader, uniformLocation, oscMessage.values, SHADER_UNIFORM_VEC2);
                    break;
                case 3:  // vec3
                    SetShaderValue(shader, uniformLocation, oscMessage.values, SHADER_UNIFORM_VEC3);
                    break;
                case 4:  // vec4
                    SetShaderValue(shader, uniformLocation, oscMessage.values, SHADER_UNIFORM_VEC4);
                    break;
                default:
                    printf("Error: Unsupported value count: %d\n", oscMessage.value_count);
                    break;
            }

            storeUniformValue(oscMessage.path, oscMessage.values, oscMessage.value_count);

        }


        prevFrameLoc = GetShaderLocation(shader, "prevFrame");

        BeginTextureMode(currentFrame);
            ClearBackground(RAYWHITE);  // Clear to black or any desired color
            BeginShaderMode(shader);
                SetShaderValueTexture(shader, prevFrameLoc, prevFrame.texture); //For some reason it's important to set this shader texture value INSIDE the shader mode!
                DrawRectangle(0, 0, screenWidth, screenHeight, RAYWHITE);
            EndShaderMode();
        EndTextureMode();

        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawTextureRec(currentFrame.texture, (Rectangle){ 0, 0, (float)currentFrame.texture.width, (float)-currentFrame.texture.height }, (Vector2){ 0, 0 }, RAYWHITE);
        EndDrawing();

        BeginTextureMode(prevFrame);
            ClearBackground(RAYWHITE);
            DrawTextureRec(currentFrame.texture, 
                (Rectangle){ 0, 0, (float)currentFrame.texture.width, (float)-currentFrame.texture.height },
                (Vector2){ 0, 0 }, RAYWHITE);
        EndTextureMode();
    }

    // Cleanup
    UnloadRenderTexture(currentFrame);
    UnloadRenderTexture(prevFrame);
    UnloadShader(shader);
    //UnloadTexture(audioTexture);
    //UnloadTexture(messageTexture);
    CloseWindow();
    cleanupAudio(&device, &encoder);

    return 0;
}

