#pragma once

#include "SDL3/SDL.h"
#include <string>

namespace systems {
    class WindowSystem final {
    public:
        static WindowSystem &getInstance();

        void systemSetInfos(const std::string &title, int width, int height);
    private:
        SDL_Window *window;

        WindowSystem();
        ~WindowSystem();
    };
}