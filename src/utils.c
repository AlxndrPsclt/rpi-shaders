#include "utils.h"

// Hash function to map string paths to hash table indices (DJB2 hash algorithm)
unsigned int hash(const char* str) {
    unsigned int hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    return hash;
}
