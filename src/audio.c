#include "audio.h"
#include <math.h>
#include <stdio.h>

int16_t audioSamples[MAX_SAMPLES];
double fftInput[MAX_SAMPLES];
float fftInputFloat[MAX_SAMPLES];
fftw_complex *fftResult;
float lowfreqs = 0.0f;

float messageFloats[MESSAGE_SAMPLES]; // Definition of messageFloats

void initFFT() {
    fftResult = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * MAX_SAMPLES);
}

void computeFFT(int n, double *input, fftw_complex *output) {
    fftw_plan plan = fftw_plan_dft_r2c_1d(n, input, output, FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);
}

void audioDataCallback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount) {
    int16_t* inputSamples = (int16_t*)pInput;
    for (ma_uint32 i = 0; i < frameCount; i++) {
        audioSamples[i] = inputSamples[i];
        fftInput[i] = ((32768.0 + audioSamples[i]) / 65536.0); // Normalize
        fftInputFloat[i] = (float)fftInput[i];
    }
    computeFFT(MAX_SAMPLES, fftInput, fftResult);
    lowfreqs = sqrt(fftResult[2][0] * fftResult[2][0] + fftResult[2][1] * fftResult[2][1]);
    (void)pOutput;
}

void initAudio(ma_device* device, ma_encoder* encoder) {
    ma_device_config deviceConfig = ma_device_config_init(ma_device_type_capture);
    deviceConfig.capture.format = ma_format_s16;
    deviceConfig.capture.channels = 1;
    deviceConfig.sampleRate = 44100;
    deviceConfig.dataCallback = audioDataCallback;
    if (ma_device_init(NULL, &deviceConfig, device) != MA_SUCCESS) {
        printf("Failed to initialize capture device.\n");
    }
    ma_device_start(device);
}

void cleanupAudio(ma_device* device, ma_encoder* encoder) {
    ma_device_uninit(device);
    ma_encoder_uninit(encoder);
    fftw_free(fftResult);
}

