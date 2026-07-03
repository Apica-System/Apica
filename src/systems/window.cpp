#include "systems/window.hpp"
#include "systems/apica.hpp"
#include "systems/logger.hpp"

#include "utils/errors.hpp"
#include "utils/errors_func_call.hpp"

#include "values/string.hpp"
#include "values/bool.hpp"
#include "values/null.hpp"

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
    
    int w, h;
    SDL_GetWindowSize(this->window, &w, &h);
    if (width > 0) w = width;
    if (height > 0) h = height;

    SDL_SetWindowSize(this->window, width, height);
}

common::elements::Element *WindowSystem::setTitle(const std::vector<common::elements::Element*> &parameters) {
    common::elements::Element *argument;
    std::optional<common::elements::Element*> error = this->getArgument(parameters, argument, common::bytecodes::ApicaTypeBytecode::String);
    if (error)
        return error.value();
    
    common::values::ValueString *title_val = static_cast<common::values::ValueString*>(argument->getValue());
    SDL_SetWindowTitle(this->window, title_val->getValue().value().c_str());
    delete argument;

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

common::elements::Element *WindowSystem::setResizable(const std::vector<common::elements::Element*> &parameters) {
    common::elements::Element *argument;
    std::optional<common::elements::Element*> error = this->getArgument(parameters, argument, common::bytecodes::ApicaTypeBytecode::Bool);
    if (error)
        return error.value();
    
    common::values::ValueBool *resizable_val = static_cast<common::values::ValueBool*>(argument->getValue());
    SDL_SetWindowResizable(this->window, resizable_val->getValue().value());
    delete argument;

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

std::optional<common::elements::Element*> WindowSystem::getArgument(const std::vector<common::elements::Element*> &parameters, common::elements::Element *&argument, common::bytecodes::ApicaTypeBytecode convertion) {
    if (parameters.size() < 1)
        return utils::tooFewArguments(0, 1);
    else if (parameters.size() > 1)
        return utils::tooManyArguments(parameters.size(), 1);

    common::elements::Element *param = parameters[0]->autoConvert(convertion);
    if (param->isErrorOrController())
        return param;
    
    argument = param;
    return std::nullopt;
}