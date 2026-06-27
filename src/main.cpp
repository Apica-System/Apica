#define SDL_MAIN_USE_CALLBACKS 1
#include <SDL3/SDL.h>

#include <SDL3/SDL_main.h>
#include <SDL3/SDL_main_impl.h>

#include "systems/apica.hpp"
#include "systems/events.hpp"
#include "utils/constants.hpp"

SDL_AppResult SDL_AppInit(void**, int, char**) {
    systems::ApicaSystem::getInstance().loadApp(utils::MAIN_MENU_NAME);
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void*, SDL_Event *event) {
    if (event->type == SDL_EVENT_QUIT)
        systems::ApicaSystem::getInstance().forceQuitApp();
    else if (event->type == SDL_EVENT_KEY_DOWN && event->key.scancode == SDL_SCANCODE_ESCAPE && (event->key.mod & SDL_KMOD_CTRL))
        systems::ApicaSystem::getInstance().forceQuitApp();

    systems::EventsSystem::getInstance().handleEvent(event);
    return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void*) {
    systems::ApicaSystem &apica = systems::ApicaSystem::getInstance();
    apica.update();

    return apica.isRunning() ? SDL_APP_CONTINUE : SDL_APP_SUCCESS;
}

void SDL_AppQuit(void*, SDL_AppResult) {

}