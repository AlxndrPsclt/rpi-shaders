# GLSL Sandbox for Real-Time Shader Rendering

This project is a minimalist GLSL sandbox designed to run shaders in real-time. It captures audio input, performs FFT analysis, and allows the results to interact with shaders. The sandbox is lightweight and flexible, initially developed and tested for a **Raspberry Pi 4** running **headless Diskless Alpine Linux**.

## Features
- Real-time shader rendering using `raylib`.
- Audio capture and FFT analysis via `miniaudio` and `FFTW`.
- Shader hot-reloading for dynamic updates during performance.
- Designed for headless environments, but adaptable to desktop usage.

## Requirements

### System Setup
The sandbox was developed on **Alpine Linux** for **Raspberry Pi 4**, but it can potentially work on other Linux distributions, as well as on other platforms such as other Linux environments (not tested and not supported officially).

### Dependencies
You need to install the following packages and libraries depending on your system:

#### For Alpine Linux:
```sh
# Install build tools and dependencies
apk add build-base gcc git raylib-dev fftw-dev alsa-lib-dev ck-dev uthash-dev liblo-dev mesa-dri-gallium
```

#### For Debian-based systems (e.g., Ubuntu, Raspberry Pi OS) (untested and not supported officially!):
```sh
sudo apt update
sudo apt install build-essential gcc git libfftw3-dev libraylib-dev libasound2-dev
```

#### For other Linux distributions (untested and not supported officially!):
Use your respective package manager to install:
- GCC (or an equivalent C compiler)
- FFTW3 development libraries
- Raylib development libraries
- ALSA or other audio libraries (depending on platform)
- CMake (optional)

### Cloning the Repository
```sh
git clone https://github.com/yourrepo/glsl-sandbox.git
cd glsl-sandbox
```

### Compilation
To compile the project for the platform you're working on, use:
```sh
make PLATFORM=PI
```
or
```sh
make PLATFORM=DESKTOP
```

- `PLATFORM=PI`: Compiles the sandbox for Raspberry Pi (targeting DRM and GLES environments).
- `PLATFORM=DESKTOP`: Compiles for desktop environments using GL.

After compilation, the output binary will be placed in the `build/` directory. To run the sandbox:
```sh
./build/myshader
```

## Adding or Modifying Shaders

### Modifying an Existing Shader
1. Navigate to the `resources/shaders` directory:
   ```sh
   cd resources/shaders
   ```
2. Open the existing shader file (`myshader.glsl`) in your text editor:
   ```sh
   nano myshader.glsl
   ```
   Modify the GLSL code as required, using available uniforms such as `lowfreqs` (FFT data), `resolution` (screen size), and `time`.

3. Save and exit the editor. The sandbox automatically hot-reloads shaders on file modification, so there’s no need to restart the application.

### Adding a New Shader
1. Create a new shader file in the `resources/shaders` directory:
   ```sh
   touch resources/shaders/newshader.glsl
   ```
2. Add your custom GLSL code. For example:
   ```glsl
   #version 330

   uniform vec2 resolution;
   uniform float time;

   void main() {
       vec2 st = gl_FragCoord.xy / resolution.xy;
       vec3 color = vec3(0.0);
       color = vec3(st.x, st.y, abs(sin(time)));
       gl_FragColor = vec4(color, 1.0);
   }
   ```
3. Modify `main.c` or any relevant part of the code to load and apply your new shader by changing the shader path.

4. Recompile and run the sandbox to see the shader in action.

## License
This project is licensed under the MIT License. See the [MIT-LICENSE.txt](./MIT-LICENSE.txt) file for details.
