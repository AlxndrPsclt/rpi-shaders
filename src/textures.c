#include "raylib.h"
#include "textures.h"
#include <stddef.h>  // For NULL

void initAudioTexture(Texture2D* audioTexture, Shader shader, int audioTextureLoc) {
    // Initialize a blank texture with the specified size
    Image audioImage = GenImageColor(1024, 1, BLANK);  // Create a blank image
    *audioTexture = LoadTextureFromImage(audioImage);  // Load the image into a texture
    UnloadImage(audioImage);  // Once the texture is created, the image can be unloaded

    SetShaderValueTexture(shader, audioTextureLoc, *audioTexture);
}

void initMessageTexture(Texture2D* messageTexture, Shader shader, int messageTextureLoc) {
    // Initialize a blank texture with the specified size
    Image messageImage = GenImageColor(100, 1, BLANK);  // Create a blank image
    *messageTexture = LoadTextureFromImage(messageImage);  // Load the image into a texture
    UnloadImage(messageImage);  // Once the texture is created, the image can be unloaded

    SetShaderValueTexture(shader, messageTextureLoc, *messageTexture);
}

