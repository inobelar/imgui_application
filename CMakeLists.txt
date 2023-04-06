cmake_minimum_required(VERSION 3.22.1)

project(imgui_application)

SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_CXX_EXTENSIONS off)

message(STATUS "[Lib ImGui App] Build type: ${CMAKE_BUILD_TYPE}")

# ----------------------------------------------------------

set(IMGUI_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui-1.89.4/")

set(LIB_INCLUDE_DIRECTORIES

    # ImGui + backends includes
    ${IMGUI_DIR}/
    ${IMGUI_DIR}/backends/

    # ImGui_Application includes
    ${CMAKE_CURRENT_SOURCE_DIR}/include/
)

# ----------------------------------------------------------
# Export (by using PARENT_SCOPE) public variables to be
# usable in parent scope:

#[[
    Exported IMGUI_APPLICATION_INCLUDE_DIRECTORIES must be
    used to add that path into includes search pathes:

    add_subdirectory(imgui_application)

    add_executable(${CMAKE_PROJECT_NAME}
        "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp"
    )

    target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
        ${IMGUI_APPLICATION_INCLUDE_DIRECTORIES}
    )

    target_link_libraries(${CMAKE_PROJECT_NAME}
        imgui_application GL
    )
]]
set(IMGUI_APPLICATION_INCLUDE_DIRECTORIES

    # ImGui includes
    ${IMGUI_DIR}/

    # ImGui_Application includes
    ${CMAKE_CURRENT_SOURCE_DIR}/include/

    PARENT_SCOPE
)

#[[
    Exported IMGUI_APPLICATION_SHELL_MINIMAL may be used as
    path for that shell:

    if(EMSCRIPTEN)
        target_link_options(${CMAKE_PROJECT_NAME} PRIVATE
            -sWASM=1

            # ...

            --shell-file ${IMGUI_APPLICATION_SHELL_MINIMAL}
        )
    endif()
]]
set(IMGUI_APPLICATION_SHELL_MINIMAL
    ${CMAKE_CURRENT_SOURCE_DIR}/web_shell/shell_minimal.html

    PARENT_SCOPE
)

# ----------------------------------------------------------



set(LIB_HEADERS

    # ImGui headers
    ${IMGUI_DIR}/imconfig.h
    ${IMGUI_DIR}/imgui.h
    ${IMGUI_DIR}/imgui_internal.h

    ${IMGUI_DIR}/imstb_rectpack.h
    ${IMGUI_DIR}/imstb_textedit.h
    ${IMGUI_DIR}/imstb_truetype.h

    ${IMGUI_DIR}/misc/cpp/imgui_stdlib.h

    # ImGui backends headers
    ${IMGUI_DIR}/backends/imgui_impl_opengl3_loader.h
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.h
    ${IMGUI_DIR}/backends/imgui_impl_sdl2.h

    # ImGui_Application headers
    ${CMAKE_CURRENT_SOURCE_DIR}/include/imgui_app/ImGui_Application.hpp
)

set(LIB_SOURCES

    # ImGui sources
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/imgui_tables.cpp

    ${IMGUI_DIR}/imgui_demo.cpp

    ${IMGUI_DIR}/misc/cpp/imgui_stdlib.cpp

    # ImGui backends sources
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdl2.cpp

    # ImGui_Application sources
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/ImGui_Application.cpp
)

add_library(${PROJECT_NAME} STATIC
    ${LIB_HEADERS} ${LIB_SOURCES}
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${LIB_INCLUDE_DIRECTORIES}
)

target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall -Wformat -Wextra -Wpedantic
)

if(EMSCRIPTEN)

    message(STATUS "[Lib ImGui App] Platform: EMSCRIPTEN")

    target_compile_definitions(${PROJECT_NAME} PRIVATE
        IMGUI_DISABLE_FILE_FUNCTIONS
    )

    target_compile_options(${PROJECT_NAME} PRIVATE
        -s USE_SDL=2
    )

else()

    message(STATUS "[Lib ImGui App] Platform: Native")

    find_package(SDL2 REQUIRED)

    target_include_directories(${PROJECT_NAME} PRIVATE
        ${SDL2_INCLUDE_DIRS}
    )

    target_link_libraries(${PROJECT_NAME}
        ${SDL2_LIBRARIES}
    )

endif()
