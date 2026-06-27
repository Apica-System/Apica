#include "systems/window.hpp"
#include "systems/apica.hpp"
#include "systems/logger.hpp"

#include "utils/errors.hpp"

using namespace systems;

WindowSystem &WindowSystem::getInstance() {
    static WindowSystem instance;
    return instance;
}

WindowSystem::WindowSystem() {
    this->window = SDL_CreateWindow("Apica", 1080, 720, 0);
    if (!this->window) {
        ApicaSystem::getInstance().setQuitFinished();
        LoggerSystem::getInstance().systemLognError(std::string(utils::WDW_ERROR_CREATE_WINDOW));
    }
}

WindowSystem::~WindowSystem() {
    if (this->window)
        SDL_DestroyWindow(this->window);
}

void WindowSystem::systemSetInfos(const std::string &title, int width, int height) {
    SDL_SetWindowTitle(this->window, title.c_str());
    SDL_SetWindowSize(this->window, width, height);
}