# ImGui Application

This tiny library is wrapper around `Dear ImGui` and its backends (currently
used `SDL 2` with `OpenGL 3`), designed to hide boilerplate with window
management and provide a simple way for making ui-focused applications.

The **main goal** of this library - to make it easy to bootstrap & create GUI 
web applications with C++ stack, without touching web stack (like html, 
javascript, etc), and the same native apps (without drastical changes in code).

This library suitable for making standalone single-page web-hosted interactive
examples, playgrounds, GUI's for C++ libraries, etc.

## Example of usage

- `main.cpp`

    ```cpp
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
    ```

- `CMakeLists.txt`

    ```cmake
    cmake_minimum_required(VERSION 3.22.1)

    project(demo_imgui_app)

    # Allow to use `$ make VERBOSE=1;`
    set(CMAKE_VERBOSE_MAKEFILE, on)

    message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

    SET(CMAKE_CXX_STANDARD 11)
    SET(CMAKE_CXX_STANDARD_REQUIRED on)
    set(CMAKE_CXX_EXTENSIONS off)

    # ----------------------------------------------------------

    add_subdirectory(imgui_application)

    add_executable(${CMAKE_PROJECT_NAME}
        "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp"
    )

    target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
        ${IMGUI_APPLICATION_INCLUDE_DIRECTORIES}
    )

    if(EMSCRIPTEN)

        # IMPORTANT NOTE: due to `target_link_options` deduplication,
        # we use "-sWASM=1 -sUSE_SDL=2 ..." which works well, instead of
        # "-s WASM=1 -s USE_SDL=2 ..." (with spaces), which becomes
        # "-s WASM=1 USE_SDL=2 ..." (duplicated but necessary '-s' removed).

        target_link_options(${CMAKE_PROJECT_NAME} PRIVATE
            -sWASM=1
            -sUSE_SDL=2

            -sUSE_WEBGL2=1
            #-sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2 # Only target for WebGL2 (drop support for WebGL1 to save code size)

            -sALLOW_MEMORY_GROWTH=1
            -sDISABLE_EXCEPTION_CATCHING=1 -sNO_EXIT_RUNTIME=0 -sASSERTIONS=1

            -sNO_FILESYSTEM=1

            -sSINGLE_FILE

            --shell-file ${IMGUI_APPLICATION_SHELL_MINIMAL}
        )

        target_link_libraries(${CMAKE_PROJECT_NAME}
            imgui_application
        )

        set(CMAKE_EXECUTABLE_SUFFIX ".html")

    else()

        target_link_libraries(${CMAKE_PROJECT_NAME}
            imgui_application GL
        )

    endif()
    ```

- Build web-based app:

    ```shell
    # Setup EMSDK environment
    $ source ~/path/to/emsdk/emsdk_env.sh

    # Make build directory and go into it
    $ mkdir ./build/; cd ./build/

    # Generate Makefile for building web-based app
    $ emcmake cmake -DCMAKE_BUILD_TYPE=Release ../

    # Build
    $ make VERBOSE=1 -j4

    # Launch web-server for hosting necessary html/js/wasm and open page in browser
    $ emrun ./demo_imgui_app.html
    ```

- Build native app:

    ```shell
    # Make build directory and go into it
    $ mkdir ./build/; cd ./build/

    # Generate Makefile for building web-based app
    $ cmake -DCMAKE_BUILD_TYPE=Release ../

    # Build
    $ make VERBOSE=1 -j4

    # Run app
    $ ./demo_imgui_app
    ```

----

For hacking without `CMake` (for testing/example purpose) here is present the
next 2 files:
1. `$ bash ./build_emscripten_lib.sh` - make only library and place into
`./build/` directory
2. `$ bash ./build_emscripten_test_app.sh` - make test application (library must
be already built).
