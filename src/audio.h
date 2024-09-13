#ifndef AUDIO_H
#define AUDIO_H

#include "miniaudio.h"
#include <fftw3.h>
#include <stdint.h>

#define MAX_SAMPLES 1024

#define MESSAGE_SAMPLES 100
extern float messageFloats[MESSAGE_SAMPLES];

extern int16_t audioSamples[MAX_SAMPLES];
extern double fftInput[MAX_SAMPLES];
extern float fftInputFloat[MAX_SAMPLES];
extern fftw_complex *fftResult;
extern float lowfreqs;

void initFFT();
void computeFFT(int n, double *input, fftw_complex *output);
void audioDataCallback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount);
void initAudio(ma_device* device, ma_encoder* encoder);
void cleanupAudio(ma_device* device, ma_encoder* encoder);

#endif // AUDIO_H

