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
#include <fftw3.h>

#include <stdlib.h>
#include <stdio.h>

#include "raylib.h"
#include "rlgl.h"

#include <lo/lo.h>

#include <time.h>       // Required for: localtime(), asctime()

#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_ANDROID, PLATFORM_WEB
    #define GLSL_VERSION            100
#endif

//#define MAX_SAMPLES 44100 * 10   // For example, 10 seconds at 44100 Hz.
#define MAX_SAMPLES 1024
int16_t audioSamples[MAX_SAMPLES];
double fftInput[MAX_SAMPLES];
float fftInputFloat[MAX_SAMPLES];
float oscVal01 = 0.0;


fftw_complex *fftResult;

float lowfreqs = 0.0f;

void computeFFT(int n, double *input, fftw_complex *output)
{
    fftw_plan plan = fftw_plan_dft_r2c_1d(n, input, output, FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);
}

void audioDataCallback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    int16_t* inputSamples = (int16_t*)pInput;

    //printf("FrameCount %u\n", frameCount);

    for(ma_uint32 i = 0; i < frameCount; i++)
    {
        audioSamples[i] = (inputSamples[i]);
        fftInput[i] = ((32768.0+audioSamples[i]) / 65536.0);  // Convert to double and normalize
        fftInputFloat[i] = (float)fftInput[i];
    }

    computeFFT(MAX_SAMPLES, fftInput, fftResult);

    lowfreqs = sqrt(fftResult[2][0] * fftResult[2][0] + fftResult[2][1] * fftResult[2][1]);
    //printf("Audio %f\n", fftInput[2]);
    //printf("FFT %f %f\n", fftResult[2][0], fftResult[2][1]);
    //printf("FFT %f\n", lowfreqs);

    (void)pOutput;
}


// Error handler
void error(int num, const char *msg, const char *path) {
    fprintf(stderr, "liblo server error %d: %s\n", num, msg);
    if (path) fprintf(stderr, "Path: %s\n", path);
}

// Generic handler for any OSC message
int generic_handler(const char *path, const char *types, lo_arg **argv, 
                    int argc, void *data, void *user_data) {
    printf("Received OSC message: path='%s', types='%s', argc=%d\n", path, types, argc);
    for (int i = 0; i < argc; i++) {
        printf("Argument %d: ", i);
        lo_arg_pp((lo_type)types[i], argv[i]);
        printf("\n");
        oscVal01 = argv[i];
    }
    printf("\n");
    return 0;
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

    lo_server_thread st = lo_server_thread_new("12345", error);
    lo_server_thread_add_method(st, NULL, NULL, generic_handler, NULL);


    fftResult = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * MAX_SAMPLES);

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
    int lowfreqsLoc = GetShaderLocation(shader, "lowfreqs");
    int oscVal01Loc = GetShaderLocation(shader, "oscVal01");
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
    SetShaderValue(shader, lowfreqsLoc, &lowfreqs, SHADER_UNIFORM_FLOAT);


    float resolution[2] = { (float)screenWidth, (float)screenHeight };
    SetShaderValue(shader, resolutionLoc, resolution, SHADER_UNIFORM_VEC2);

    float totalTime = 0.0f;
    bool shaderAutoReloading = true;

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    ma_result result;
    ma_encoder_config encoderConfig;
    ma_encoder encoder;
    ma_device_config deviceConfig;
    ma_device device;


    //encoderConfig = ma_encoder_config_init(ma_encoding_format_wav, ma_format_f32, 2, 44100);
    encoderConfig = ma_encoder_config_init(ma_encoding_format_wav, ma_format_s16, 1, 44100);    //PLATFORM RPI


    if (ma_encoder_init_file("/tmp/test.wav", &encoderConfig, &encoder) != MA_SUCCESS) {
        printf("Failed to initialize output file.\n");
        return -1;
    }

    deviceConfig = ma_device_config_init(ma_device_type_capture);
    deviceConfig.capture.format   = encoderConfig.format;
    deviceConfig.capture.channels = encoderConfig.channels;
    deviceConfig.sampleRate       = encoderConfig.sampleRate;
    deviceConfig.dataCallback     = audioDataCallback;
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

    lo_server_thread_start(st);

    // Main visualization loop
    while (!WindowShouldClose())            // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        totalTime += GetFrameTime();
        Vector2 mouse = GetMousePosition();
        float mousePos[2] = { mouse.x, mouse.y };

        // Set shader required uniform values
        SetShaderValue(shader, timeLoc, &totalTime, SHADER_UNIFORM_FLOAT);
        SetShaderValue(shader, mouseLoc, mousePos, SHADER_UNIFORM_VEC2);
        SetShaderValue(shader, lowfreqsLoc, &lowfreqs, SHADER_UNIFORM_FLOAT);
        SetShaderValue(shader, oscVal01Loc, &oscVal01, SHADER_UNIFORM_FLOAT);

        UpdateTexture(audioTexture, fftInputFloat);

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
                DrawRectangle(0, 0, screenWidth, screenHeight, BLACK);
            EndShaderMode();

            //DrawText(TextFormat("Shader last modification: %s", asctime(localtime(&fragShaderFileModTime))), 10, 1040, 20, WHITE);

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
    fftw_free(fftResult);
    lo_server_thread_free(st);
    //--------------------------------------------------------------------------------------

    return 0;
}
