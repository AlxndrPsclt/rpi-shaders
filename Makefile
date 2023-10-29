# Compiler and flags
CC = gcc

# Platform-specific settings
ifeq ($(PLATFORM),DESKTOP)
CFLAGS = -std=c99 -Wall -DPLATFORM_DESKTOP
else ifeq ($(PLATFORM),PI)
CFLAGS = -std=c99 -Wall -DPLATFORM_DRM
else
$(error PLATFORM variable is not set or recognized. Please use PLATFORM=DESKTOP or PLATFORM=PI)
endif

# Libraries
LIBS =  -lraylib -lfftw3 -L/home/alex/raylib/src -lGLESv2 -lEGL -ldrm -lgbm -lpthread -lrt -lm -ldl
LDFLAGS = -lGL -lm -lpthread -ldl -lrt -ldrm 

# Source files and object files
SRC = myshader.c
OBJ = $(SRC:.c=.o)

# Output executable
OUT = myshader

# Build rules

all: $(OUT)

$(OUT): $(OBJ)
	$(CC) $(OBJ) -o $@ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ -g

clean:
	rm -f $(OBJ) $(OUT)

