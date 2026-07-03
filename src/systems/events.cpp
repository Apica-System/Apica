#include "systems/events.hpp"
#include "values/bool.hpp"
#include "values/u32.hpp"
#include "utils/errors_func_call.hpp"

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

common::elements::Element *EventsSystem::isKeyPressed(const std::vector<common::elements::Element*> &parameters) {
    uint32_t scancode;
    std::optional<common::elements::Element*> error = this->getScancode(parameters, &scancode);
    if (error)
        return error.value();

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueBool(this->current_key_states[scancode])
    );
}

common::elements::Element *EventsSystem::isKeyReleased(const std::vector<common::elements::Element*> &parameters) {
    uint32_t scancode;
    std::optional<common::elements::Element*> error = this->getScancode(parameters, &scancode);
    if (error)
        return error.value();

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueBool(!this->current_key_states[scancode])
    );
}

common::elements::Element *EventsSystem::isKeyJustPressed(const std::vector<common::elements::Element*> &parameters) {
    uint32_t scancode;
    std::optional<common::elements::Element*> error = this->getScancode(parameters, &scancode);
    if (error)
        return error.value();

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueBool(this->current_key_states[scancode] && !this->previous_key_states[scancode])
    );
}

common::elements::Element *EventsSystem::isKeyJustReleased(const std::vector<common::elements::Element*> &parameters) {
    uint32_t scancode;
    std::optional<common::elements::Element*> error = this->getScancode(parameters, &scancode);
    if (error)
        return error.value();

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueBool(!this->current_key_states[scancode] && this->previous_key_states[scancode])
    );
}

std::optional<common::elements::Element*> EventsSystem::getScancode(const std::vector<common::elements::Element*> &parameters, uint32_t *scancode) {
    if (parameters.size() < 1)
        return utils::tooFewArguments(0, 1);
    else if (parameters.size() > 1)
        return utils::tooManyArguments(parameters.size(), 1);

    common::elements::Element *param = parameters[0]->autoConvert(common::bytecodes::ApicaTypeBytecode::U32);
    if (param->isErrorOrController())
        return param;
    
    common::values::ValueU32 *scancode_value = static_cast<common::values::ValueU32*>(param->getValue());
    std::optional<uint32_t> code = scancode_value->getValue();
    delete param;
    if (!code || code.value() >= SDL_SCANCODE_COUNT)
        return utils::assertionFailed("Scancode cannot be null nor greater or equals than 512");
    
    *scancode = code.value();
    return std::nullopt;
}