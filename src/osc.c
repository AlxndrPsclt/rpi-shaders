#include <lo/lo.h>
#include <ck_ring.h>
#include <stdio.h>
#include <stdlib.h>  // For malloc
#include <string.h>
#include "osc.h"
#include "config.h"

// Global OSC queue
OSCQueue oscQueue;

void initOSCQueue(int size) {
    oscQueue.buffer = malloc(sizeof(ck_ring_buffer_t) * size);  // Dynamically allocate buffer for messages
    if (oscQueue.buffer == NULL) {
        printf("Failed to allocate memory for OSC message queue\n");
        return;
    }
    ck_ring_init(&oscQueue.ring, size);
}

void enqueueOSCMessage(OSCMessage message) {
    OSCMessage *messageCopy = malloc(sizeof(OSCMessage));  // Allocate memory for message
    if (messageCopy == NULL) {
        printf("Failed to allocate memory for OSC message copy\n");
        return;
    }
    memcpy(messageCopy, &message, sizeof(OSCMessage));  // Copy the message to avoid stack issues
    if (!ck_ring_enqueue_mpmc(&oscQueue.ring, oscQueue.buffer, messageCopy)) {
        printf("Queue full, message dropped\n");
        free(messageCopy);  // Free memory if enqueue fails
    }
}

OSCMessage dequeueOSCMessage() {
    OSCMessage *message;
    if (!ck_ring_dequeue_mpmc(&oscQueue.ring, oscQueue.buffer, (void **)&message)) {
        printf("Queue empty\n");
        OSCMessage emptyMessage = { .path = "", .values = {0.0f}, .value_count = 0 };
        return emptyMessage;
    }

    OSCMessage returnMessage = *message;
    free(message);  // Free the dynamically allocated memory after dequeuing
    return returnMessage;
}

int oscHandler(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data) {
    if (argc < 1 || argc > 4) {
        printf("Error: Only 1 to 4 float arguments are supported.\n");
        return 1;  // Exit if argument count is outside of 1–4
    }

    OSCMessage oscMessage;
    snprintf(oscMessage.path, MAX_PATH_SIZE, "%s", path + 1);  // Skip the leading '/'
    
    oscMessage.value_count = argc;  // Store the number of arguments

    // Store up to 4 float arguments
    for (int i = 0; i < argc; i++) {
        if (types[i] == 'f') {  // Ensure the argument is a float
            oscMessage.values[i] = argv[i]->f;
        } else {
            printf("Unsupported argument type: %c\n", types[i]);
            return 1;
        }
    }

    printf("Received an OSC message at path: %s with %d float(s)\n", oscMessage.path, oscMessage.value_count);
    enqueueOSCMessage(oscMessage);  // Add the message to the queue
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
