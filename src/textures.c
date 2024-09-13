#include "raylib.h"
#include "textures.h"
#include <stddef.h>  // For NULL

void initAudioTexture(Texture2D* audioTexture, Shader shader, int audioTextureLoc) {
    audioTexture->width = 1024;
    audioTexture->height = 1;
    audioTexture->mipmaps = 1;
    audioTexture->format = PIXELFORMAT_UNCOMPRESSED_R32;
    unsigned int textureId = rlLoadTexture(NULL, audioTexture->width, audioTexture->height, audioTexture->format, 1);
    audioTexture->id = textureId;
    SetShaderValueTexture(shader, audioTextureLoc, *audioTexture);
}

void initMessageTexture(Texture2D* messageTexture, Shader shader, int messageTextureLoc) {
    messageTexture->width = 100;
    messageTexture->height = 1;
    messageTexture->mipmaps = 1;
    messageTexture->format = PIXELFORMAT_UNCOMPRESSED_R32;
    unsigned int textureId = rlLoadTexture(NULL, messageTexture->width, messageTexture->height, messageTexture->format, 1);
    messageTexture->id = textureId;
    SetShaderValueTexture(shader, messageTextureLoc, *messageTexture);
}

