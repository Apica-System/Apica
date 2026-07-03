#pragma once

#include <SDL3/SDL.h>
#include <string>
#include <vector>

#include "elements.hpp"

namespace systems {
    class WindowSystem final {
    public:
        static WindowSystem &getInstance();

        void systemSetInfos(const std::string &title, int width, int height);

        common::elements::Element *setTitle(const std::vector<common::elements::Element*> &parameters);
        common::elements::Element *setResizable(const std::vector<common::elements::Element*> &parameters);
    private:
        SDL_Window *window;

        WindowSystem();
        ~WindowSystem();

        std::optional<common::elements::Element*> getArgument(const std::vector<common::elements::Element*> &parameters, common::elements::Element *&argument, common::bytecodes::ApicaTypeBytecode convertion);
    };
}