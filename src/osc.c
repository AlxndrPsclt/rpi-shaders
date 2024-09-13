#include "osc.h"
#include "config.h"  // Include the config file for OSC settings
#include <stdio.h>
#include <string.h>
#include <lo/lo.h>

// Global variables to store the OSC-received data
float oscFloat = 0.0f;
int oscInt = 0;
float oscVec3[3] = {0.0f, 0.0f, 0.0f};

// Functions to retrieve the values
float getOscFloat() {
    return oscFloat;
}

int getOscInt() {
    return oscInt;
}

float* getOscVec3() {
    return oscVec3;
}

// OSC message handler
int oscHandler(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data) {
    printf("OSC message received:\n");
    printf("Path: %s\n", path);
    
    if (strcmp(path, "/osc/float") == 0 && argc > 0 && types[0] == 'f') {
        oscFloat = argv[0]->f;
        printf("Received float: %f\n", oscFloat);
    } 
    else if (strcmp(path, "/osc/int") == 0 && argc > 0 && types[0] == 'i') {
        oscInt = argv[0]->i;
        printf("Received int: %d\n", oscInt);
    } 
    else if (strcmp(path, "/osc/vec3") == 0 && argc >= 3 && types[0] == 'f' && types[1] == 'f' && types[2] == 'f') {
        oscVec3[0] = argv[0]->f;
        oscVec3[1] = argv[1]->f;
        oscVec3[2] = argv[2]->f;
        printf("Received vec3: [%f, %f, %f]\n", oscVec3[0], oscVec3[1], oscVec3[2]);
    } 
    else {
        printf("Unrecognized path or argument types\n");
    }

    return 0;
}

void startOscServer() {
    // Create OSC server on the specified port, bind to all interfaces (0.0.0.0)
    lo_server_thread st = lo_server_thread_new(OSC_PORT, NULL);

    if (!st) {
        printf("Failed to create OSC server on port %s\n", OSC_PORT);
        return;
    }
    
    // Add OSC message handler for any path
    lo_server_thread_add_method(st, NULL, NULL, oscHandler, NULL);
    
    // Start the server
    lo_server_thread_start(st);
    printf("OSC server started on 0.0.0.0:%s\n", OSC_PORT);
}

