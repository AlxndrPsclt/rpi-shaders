#ifndef OSC_H
#define OSC_H

#include <lo/lo.h>

void startOscServer();

// Functions to retrieve the OSC data for different uniforms
float getOscFloat();
int getOscInt();
float* getOscVec3();

#endif // OSC_H

