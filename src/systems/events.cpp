#include "systems/events.hpp"

using namespace systems;

EventsSystem &EventsSystem::getInstance() {
    static EventsSystem instance;
    return instance;
}

EventsSystem::EventsSystem() {
    memset(this->raw_key_states, 0, sizeof(this->raw_key_states));
    memset(this->current_key_states, 0, sizeof(this->current_key_states));
    memset(this->previous_key_states, 0, sizeof(this->previous_key_states));
}

EventsSystem::~EventsSystem() {

}

void EventsSystem::handleEvent(const SDL_Event *event) {
    if (event->type == SDL_EVENT_KEY_DOWN) {
        if (!event->key.repeat)
            this->raw_key_states[event->key.scancode] = true;
    } else if (event->type == SDL_EVENT_KEY_UP) {
        this->raw_key_states[event->key.scancode] = false;
    }
}

void EventsSystem::handleNewTick() {
    memcpy(this->previous_key_states, this->current_key_states, sizeof(this->current_key_states));
    memcpy(this->current_key_states, this->raw_key_states, sizeof(this->raw_key_states));
}