#include <SDL3/SDL.h>

#include "systems/apica.hpp"

int main() {
    systems::ApicaSystem &apica = systems::ApicaSystem::getInstance();

    printf("SDL %d.%d.%d\n", SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);

    while (apica.isRunning())
        apica.update();

    return 0;
}