#pragma once

#include "elements.hpp"

#include <SDL3/SDL.h>
#include <vector>

namespace systems {
    class EventsSystem final {
    public:
        static EventsSystem &getInstance();

        void handleEvent(const SDL_Event *event);
        void handleNewTick();

        common::elements::Element *isKeyPressed(const std::vector<common::elements::Element*> &parameters);
        common::elements::Element *isKeyReleased(const std::vector<common::elements::Element*> &parameters);
        common::elements::Element *isKeyJustPressed(const std::vector<common::elements::Element*> &parameters);
        common::elements::Element *isKeyJustReleased(const std::vector<common::elements::Element*> &parameters);
    private:
        bool raw_key_states[SDL_SCANCODE_COUNT];
        bool current_key_states[SDL_SCANCODE_COUNT];
        bool previous_key_states[SDL_SCANCODE_COUNT];

        EventsSystem();
        ~EventsSystem();

        EventsSystem(EventsSystem &) = delete;
        void operator=(const EventsSystem &) = delete;

        std::optional<common::elements::Element*> getScancode(const std::vector<common::elements::Element*> &parameters, uint32_t *scancode);
    };
}