#include "utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Hash function to map string paths to hash table indices (DJB2 hash algorithm)
unsigned int hash(const char* str) {
    unsigned int hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    return hash;
}

char* replace_slash_with_underscore(const char *str) {
    // Allocate memory for the new string
    char *new_str = malloc(strlen(str) + 1);  // +1 for null terminator
    if (new_str == NULL) {
        perror("Failed to allocate memory");
        return NULL;
    }

    // Iterate through the original string, replacing '/' with '_'
    const char *src = str;
    char *dst = new_str;

    while (*src) {
        *dst = (*src == '/') ? '_' : *src;
        src++;
        dst++;
    }

    *dst = '\0'; // Null-terminate the new string
    return new_str;
}
