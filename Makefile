# Compiler and flags
CC = gcc
#CFLAGS = -std=c99 -Wall -DPLATFORM_DRM
CFLAGS = -std=c99 -Wall -DPLATFORM_DESKTOP


# Libraries
# LIBS = -lraylib -lGL -lm -lpthread -ldl -lrt -ldrm
LIBS =  -lraylib -L/home/alex/raylib/src -lGLESv2 -lEGL -ldrm -lgbm -lpthread -lrt -lm -ldl
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
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(OUT)

