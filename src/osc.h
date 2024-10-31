#ifndef OSC_H
#define OSC_H

#include <ck_ring.h>

#define MAX_PATH_SIZE 32
#define QUEUE_SIZE 1024  // Define the queue size

typedef struct {
    char path[MAX_PATH_SIZE];  // Path (minus the '/')
    float values[4];           // Array of values (supporting up to 8 floats)
    int value_count;           // Number of arguments
} __attribute__((aligned(8))) OSCMessage;


// Queue structure
typedef struct {
    ck_ring_t ring;
    ck_ring_buffer_t *buffer;
} OSCQueue;

extern OSCQueue oscQueue;

void initOSCQueue(int size);
void enqueueOSCMessage(OSCMessage message);
OSCMessage dequeueOSCMessage();
void startOscServer();

#endif  // OSC_H

