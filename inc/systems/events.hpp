#pragma once

#include "elements.hpp"
#include <SDL3/SDL.h>

namespace systems {
    class EventsSystem final {
    public:
        static EventsSystem &getInstance();

        void handleEvent(const SDL_Event *event);
        void handleNewTick();

        common::elements::Element *isKeyDown(SDL_Scancode scancode);
        common::elements::Element *isKeyUp(SDL_Scancode scancode);
        common::elements::Element *isKeyPressed(SDL_Scancode scancode);
        common::elements::Element *isKeyReleased(SDL_Scancode scancode);
    private:
        bool raw_key_states[SDL_SCANCODE_COUNT];
        bool current_key_states[SDL_SCANCODE_COUNT];
        bool previous_key_states[SDL_SCANCODE_COUNT];

        EventsSystem();
        ~EventsSystem();

        EventsSystem(EventsSystem &) = delete;
        void operator=(const EventsSystem &) = delete;
    };
}