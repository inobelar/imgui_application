#!/usr/bin/env bash

# ------------------------------------------------------------------------------

# (Re)Make 'build' directory (to make clean build) and go into it
rm -rf ./build/
mkdir -p ./build/
cd ./build/

# ------------------------------------------------------------------------------
# ImGui + backend + App

IMGUI_PATH="../third_party/imgui-1.89.7"

CPP_FLAGS=
CPP_FLAGS+=" -std=c++11"
CPP_FLAGS+=" -Wall -Wformat -Wextra -Wpedantic"
CPP_FLAGS+=" -Os" # Size optimization
CPP_FLAGS+=" -D IMGUI_DISABLE_FILE_FUNCTIONS"
CPP_FLAGS+=" -s USE_SDL=2"

# Compile ImGui objects
emcc $CPP_FLAGS -I $IMGUI_PATH -c $IMGUI_PATH/imgui.cpp
emcc $CPP_FLAGS -I $IMGUI_PATH -c $IMGUI_PATH/imgui_demo.cpp
emcc $CPP_FLAGS -I $IMGUI_PATH -c $IMGUI_PATH/imgui_draw.cpp
emcc $CPP_FLAGS -I $IMGUI_PATH -c $IMGUI_PATH/imgui_tables.cpp
emcc $CPP_FLAGS -I $IMGUI_PATH -c $IMGUI_PATH/imgui_widgets.cpp

emcc $CPP_FLAGS -I $IMGUI_PATH -I $IMGUI_PATH/misc/cpp -c $IMGUI_PATH/misc/cpp/imgui_stdlib.cpp

# Compile ImGui :: OpenGL 3 backend object
emcc $CPP_FLAGS -I $IMGUI_PATH -I $IMGUI_PATH/backends -c $IMGUI_PATH/backends/imgui_impl_opengl3.cpp

# Compile ImGui :: SDL 2 backend object
emcc $CPP_FLAGS -I $IMGUI_PATH -I $IMGUI_PATH/backends -c $IMGUI_PATH/backends/imgui_impl_sdl2.cpp


# Compile ImGui_Application
emcc $CPP_FLAGS  -I ../include/ -I $IMGUI_PATH -I $IMGUI_PATH/backends -c ../sources/ImGui_Application.cpp

# ------------------------------------------------------------------------------

# Combine object files into library file
#   Reference: https://emscripten.org/docs/compiling/Building-Projects.html?highlight=link#manually-using-emcc
emar rcs \
    libimgui_application.a \
    \
    ./imgui.o \
    ./imgui_demo.o \
    ./imgui_draw.o \
    ./imgui_tables.o \
    ./imgui_widgets.o \
    ./imgui_stdlib.o \
    \
    ./imgui_impl_opengl3.o \
    ./imgui_impl_sdl2.o \
    \
    ./ImGui_Application.o

# ------------------------------------------------------------------------------
# Check build

# Test 'is library file exists' determines is everything ok
if [ -f "./libimgui_application.a" ]; then
    echo "[Lib ImGui App] Library build successful"

    # Remove all objects files - they not needed now
    rm ./*.o

    exit 0
else
    echo "[Lib ImGui App] Library build failed"
    exit 1
fi

