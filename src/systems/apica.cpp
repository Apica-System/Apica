#include "systems/apica.hpp"
#include "systems/logger.hpp"

#include "VM/evaluator.hpp"

#include "utils/errors.hpp"
#include "values/u64.hpp"
#include "values/null.hpp"
#include "utils/constants.hpp"

using namespace systems;

ApicaSystem::ApicaSystem()
    : right(utils::ApicaRight::APR_MAIN_MENU), mode(utils::ApicaMode::APM_Init), evaluator_thread(nullptr) {

}

ApicaSystem &ApicaSystem::getInstance() {
    static ApicaSystem instance;
    return instance;
}

bool ApicaSystem::isRunning() const {
    return this->mode != utils::ApicaMode::APM_SpecialQuit;
}

common::elements::Element *ApicaSystem::quitApp() {
    if (this->right & utils::ApicaRight::APR_AppRight)
        this->mode = utils::ApicaMode::APM_Quit;
    
    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

void ApicaSystem::forceQuitApp() {
    this->mode = utils::ApicaMode::APM_QuitFinished;
}

void ApicaSystem::loadApp(const std::string &name) {
    if (!(this->right & utils::ApicaRight::APR_AppRight))
        return;
    
    systems::LoggerSystem::getInstance().createLogFileFor(name);
    if (!VM::VMEvaluator::getInstance().readApp(name)) {
        this->mode = utils::APM_QuitFinished;
        return;
    }
    
    this->evaluator_thread = SDL_CreateThreadRuntime(
        VM::VMEvaluator::loop,
        "VMThread",
        nullptr,
        reinterpret_cast<SDL_FunctionPointer>(SDL_BeginThreadFunction),
        reinterpret_cast<SDL_FunctionPointer>(SDL_EndThreadFunction)
    );

    if (!this->evaluator_thread) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::EVL_ERROR_LAUNCH_THREAD));
        this->mode = utils::APM_SpecialQuit;
    }
}

utils::ApicaMode ApicaSystem::getMode() {
    utils::ApicaMode mode = this->mode;
    if (this->mode == utils::APM_Init)
        this->mode = utils::APM_Update;

    return mode;
}

void ApicaSystem::setQuitFinished() {
    this->mode = utils::APM_QuitFinished;
}

void ApicaSystem::update() {
    if (this->mode == utils::APM_QuitFinished) {
        VM::VMEvaluator::getInstance().cancel();

        int result = 0;
        SDL_WaitThread(this->evaluator_thread, &result);
        this->evaluator_thread = nullptr;

        if (this->right & utils::ApicaRight::APR_MainMenuRight) {
            this->mode = utils::ApicaMode::APM_SpecialQuit;
        } else {
            this->right = utils::ApicaRight::APR_MAIN_MENU;
            this->mode = utils::ApicaMode::APM_Init;
            this->loadApp(utils::MAIN_MENU_NAME);
        }
    }
}