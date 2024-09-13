#ifndef TEXTURES_H
#define TEXTURES_H

#include "raylib.h"

void initAudioTexture(Texture2D* audioTexture, Shader shader, int audioTextureLoc);
void initMessageTexture(Texture2D* messageTexture, Shader shader, int messageTextureLoc);

#endif // TEXTURES_H

