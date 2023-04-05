#pragma once

#include <memory> // for std::unique_ptr<T>

/**
    # Example of usage

    @code{.cpp}
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
    @endcode
*/

class ImGui_Application
{
    // PIMPL idiom
    class Impl;
    std::unique_ptr<Impl> _impl;

public:

    ImGui_Application();
    virtual ~ImGui_Application();

    virtual bool init();
    void run_main_loop();

protected:

    void set_clear_color(float r, float g, float b, float a);

    void set_window_title(const char* title);
    const char* get_window_title() const;

    virtual void draw_ui();
    virtual void draw_gl();

};
