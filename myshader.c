/*******************************************************************************************
*
*   raylib [shaders] example - Hot reloading
*
*   NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
*         is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
*
*   Example originally created with raylib 3.0, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <stdio.h>

#include "raylib.h"
#include "rlgl.h"

#include <time.h>       // Required for: localtime(), asctime()

#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_ANDROID, PLATFORM_WEB
    #define GLSL_VERSION            100
#endif

//#define MAX_SAMPLES 44100 * 10   // For example, 10 seconds at 44100 Hz.
#define MAX_SAMPLES 1102
float audioSamples[MAX_SAMPLES];
unsigned int currentSampleIndex = 0;

void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    float* inputSamples = (float*)pInput;
    for(ma_uint32 i = 0; i < frameCount; i++)
    {
        audioSamples[i] = (inputSamples[i]+ 1.0) * 0.5;
    }

    (void)pOutput;
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
int main(void)
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 1920;
    const int screenHeight = 1080;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading");

    const char *fragShaderFileName = "resources/shaders/glsl%i/myshader.glsl";
    time_t fragShaderFileModTime = GetFileModTime(TextFormat(fragShaderFileName, GLSL_VERSION));

    // Load raymarching shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    Shader shader = LoadShader(0, TextFormat(fragShaderFileName, GLSL_VERSION));

    // Get shader locations for required uniforms
    int resolutionLoc = GetShaderLocation(shader, "resolution");
    int mouseLoc = GetShaderLocation(shader, "mouse");
    int timeLoc = GetShaderLocation(shader, "time");
    int audioTextureLoc = GetShaderLocation(shader, "texture3");

    Texture2D audioTexture = { 0 };
    audioTexture.width = MAX_SAMPLES;
    audioTexture.height = 1;
    audioTexture.mipmaps = 1;
    audioTexture.format = PIXELFORMAT_UNCOMPRESSED_R32;
    unsigned int textureId = rlLoadTexture(NULL, audioTexture.width, audioTexture.height, audioTexture.format, 1);
    audioTexture.id = textureId;
    SetShaderValueTexture(shader, audioTextureLoc, audioTexture);

    Vector2 textureSize = { (float)audioTexture.width, (float)audioTexture.height };
    int textureSizeLoc = GetShaderLocation(shader, "textureSize");
    SetShaderValue(shader, textureSizeLoc, &textureSize, SHADER_UNIFORM_VEC2);


    float resolution[2] = { (float)screenWidth, (float)screenHeight };
    SetShaderValue(shader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);

    float totalTime = 0.0f;
    bool shaderAutoReloading = false;

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    ma_result result;
    ma_encoder_config encoderConfig;
    ma_encoder encoder;
    ma_device_config deviceConfig;
    ma_device device;


    encoderConfig = ma_encoder_config_init(ma_encoding_format_wav, ma_format_f32, 2, 44100);

    if (ma_encoder_init_file("/tmp/test.wav", &encoderConfig, &encoder) != MA_SUCCESS) {
        printf("Failed to initialize output file.\n");
        return -1;
    }

    deviceConfig = ma_device_config_init(ma_device_type_capture);
    deviceConfig.capture.format   = encoder.config.format;
    deviceConfig.capture.channels = encoder.config.channels;
    deviceConfig.sampleRate       = encoder.config.sampleRate;
    deviceConfig.dataCallback     = data_callback;
    deviceConfig.pUserData        = &encoder;

    result = ma_device_init(NULL, &deviceConfig, &device);
    if (result != MA_SUCCESS) {
        printf("Failed to initialize capture device.\n");
        return -2;
    }

    result = ma_device_start(&device);
    if (result != MA_SUCCESS) {
        ma_device_uninit(&device);
        printf("Failed to start device.\n");
        return -3;
    }

    //Image image = LoadImageFromTexture(audioTexture);
    //float* pixelData = (float*)image.data;
    printf("Samples: %f %f %f %f\n", audioSamples[551], audioSamples[552], audioSamples[553], audioSamples[554]);
    //printf("Pixels:  %f %f %f %f\n", pixelData[551], pixelData[552], pixelData[553], pixelData[554]);

    // Main game loop
    while (!WindowShouldClose())            // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        //printf("%f\n", audioSamples[3]);
        totalTime += GetFrameTime();
        Vector2 mouse = GetMousePosition();
        float mousePos[2] = { mouse.x, mouse.y };

        // Set shader required uniform values
        SetShaderValue(shader, timeLoc, &totalTime, SHADER_UNIFORM_FLOAT);
        SetShaderValue(shader, mouseLoc, mousePos, SHADER_UNIFORM_VEC2);

        printf("%f %f %f %f\n", audioSamples[551], audioSamples[552], audioSamples[553], audioSamples[554]);
        printf("Texture ID: : %u", audioTexture.id);
        UpdateTexture(audioTexture, audioSamples);
        //image = LoadImageFromTexture(audioTexture);
        //pixelData = (float*)image.data;
        //printf("Value: %f\n", pixelData[551]);


        // Hot shader reloading
        if (shaderAutoReloading || (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)))
        {
            long currentFragShaderModTime = GetFileModTime(TextFormat(fragShaderFileName, GLSL_VERSION));

            // Check if shader file has been modified
            if (currentFragShaderModTime != fragShaderFileModTime)
            {
                // Try reloading updated shader
                Shader updatedShader = LoadShader(0, TextFormat(fragShaderFileName, GLSL_VERSION));

                if (updatedShader.id != rlGetShaderIdDefault())      // It was correctly loaded
                {
                    UnloadShader(shader);
                    shader = updatedShader;

                    // Get shader locations for required uniforms
                    resolutionLoc = GetShaderLocation(shader, "resolution");
                    mouseLoc = GetShaderLocation(shader, "mouse");
                    timeLoc = GetShaderLocation(shader, "time");

                    // Reset required uniforms
                    SetShaderValue(shader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);
                }

                fragShaderFileModTime = currentFragShaderModTime;
            }
        }

        if (IsKeyPressed(KEY_A)) shaderAutoReloading = !shaderAutoReloading;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // We only draw a white full-screen rectangle, frame is generated in shader
            BeginShaderMode(shader);
                SetShaderValueTexture(shader, audioTextureLoc, audioTexture);
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            DrawText(TextFormat("Shader last modification: %s", asctime(localtime(&fragShaderFileModTime))), 10, 1040, 20, WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);           // Unload shader
    UnloadTexture(audioTexture);

    CloseWindow();                  // Close window and OpenGL context

    ma_device_uninit(&device);
    ma_encoder_uninit(&encoder);
    //--------------------------------------------------------------------------------------

    return 0;
}
