# Compiler and flags
CC = gcc
CFLAGS = -std=c99 -Wall -Iinclude -g  # Include the include folder for headers

# Platform-specific settings
ifeq ($(PLATFORM),DESKTOP)
CFLAGS += -DPLATFORM_DESKTOP
else ifeq ($(PLATFORM),PI)
CFLAGS += -DPLATFORM_DRM
else
$(error PLATFORM variable is not set or recognized. Please use PLATFORM=DESKTOP or PLATFORM=PI)
endif

# Libraries
LIBS = -lraylib -lfftw3 -llo -L/home/alex/raylib/src -lGLESv2 -lEGL -ldrm -lgbm -lpthread -lrt -lm -ldl

# Source files and object files
SRC_DIR = src
OBJ_DIR = build
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC))

# Output executable
OUT = build/myshader

# Build rules
all: build_dir $(OUT)

$(OUT): $(OBJ)
	$(CC) $(OBJ) -o $@ $(LIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)/* $(OUT)

build_dir:
	mkdir -p $(OBJ_DIR)

# Phony targets
.PHONY: clean build_dir

