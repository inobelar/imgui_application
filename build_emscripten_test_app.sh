#!/usr/bin/env bash

# ------------------------------------------------------------------------------

# (Re)Make 'build' directory (to make clean build) and go into it
rm -rf ./build_test_app/
mkdir -p ./build_test_app/
cd ./build_test_app/

# ------------------------------------------------------------------------------

cat << EOF > main.cpp
#include <imgui_app/ImGui_Application.hpp>

#include "imgui.h"

class MyApp : public ImGui_Application
{
protected:

    void draw_ui() override
    {
        ImGui::ShowDemoWindow();
    }
};

int main()
{
    MyApp app;
    if(!app.init())
        return 1;

    app.run_main_loop();

    return 0;
}
EOF

IMGUI_PATH="../third_party/imgui-1.89.7/"

CPP_FLAGS=
CPP_FLAGS+=" -std=c++11"
CPP_FLAGS+=" -Wall -Wformat -Wextra -Wpedantic"
CPP_FLAGS+=" -Os" # Size optimization

# Compile main file
emcc $CPP_FLAGS -I ../include/ -I $IMGUI_PATH -c ./main.cpp

# ------------------------------------------------------------------------------

EMSCRIPTEN_LINK_FLAGS=
EMSCRIPTEN_LINK_FLAGS+=" -s WASM=1"
EMSCRIPTEN_LINK_FLAGS+=" -s USE_SDL=2"

EMSCRIPTEN_LINK_FLAGS+=" -s USE_WEBGL2=1"
#EMSCRIPTEN_LINK_FLAGS+=" -s MIN_WEBGL_VERSION=2 -s MAX_WEBGL_VERSION=2" # Only target for WebGL2 (drop support for WebGL1 to save code size)

EMSCRIPTEN_LINK_FLAGS+=" -s ALLOW_MEMORY_GROWTH=1"
EMSCRIPTEN_LINK_FLAGS+=" -s DISABLE_EXCEPTION_CATCHING=1 -s NO_EXIT_RUNTIME=0 -s ASSERTIONS=1"

EMSCRIPTEN_LINK_FLAGS+=" -s NO_FILESYSTEM=1"

EMSCRIPTEN_LINK_FLAGS+=" -s SINGLE_FILE"

EMSCRIPTEN_LINK_FLAGS+=" --shell-file ../web_shell/shell_minimal.html"

# Link everything together
emcc \
    $CPP_FLAGS \
    \
    $EMSCRIPTEN_LINK_FLAGS \
    -o index.html \
    \
    ../build/libimgui_application.a \
    ./main.o

# ------------------------------------------------------------------------------
# Check build

# Test 'is file exists' determines is everything ok
if [ -f "./index.html" ]; then
    echo "Build successful"

    # Remove all objects files - they not needed now
    rm ./*.o

    # Remove generated `main.cpp`
    rm ./main.cpp

    exit 0
else
    echo "Build failed"
    exit 1
fi

