#include "systems/apica.hpp"
#include "systems/logger.hpp"

#include "VM/evaluator.hpp"

#include "utils/errors.hpp"
#include "utils/constants.hpp"
#include "utils/errors_func_call.hpp"

#include "values/u64.hpp"
#include "values/null.hpp"
#include "values/string.hpp"

using namespace systems;

ApicaSystem::ApicaSystem()
    : right(utils::ApicaRight::APR_MAIN_MENU), mode(utils::ApicaMode::APM_Init), 
    evaluator_thread(nullptr), next_app(std::nullopt) {

}

ApicaSystem &ApicaSystem::getInstance() {
    static ApicaSystem instance;
    return instance;
}

bool ApicaSystem::isRunning() const {
    return this->mode != utils::ApicaMode::APM_SpecialQuit;
}

common::elements::Element *ApicaSystem::quitApp(const std::vector<common::elements::Element*> &parameters) {
    std::optional<common::elements::Element*> error = utils::noArgumentExpected(parameters);
    if (error)
        return error.value();

    if (this->right & utils::ApicaRight::APR_AppRight)
        this->mode = utils::ApicaMode::APM_Quit;
    
    return new common::elements::Element(
        common::elements::ElementModifier::Terminate,
        new common::values::ValueNull()
    );
}

common::elements::Element *ApicaSystem::loadApp(const std::vector<common::elements::Element*> &parameters) {
    if (!(this->right & utils::ApicaRight::APR_AppRight))
        return utils::forbidden();
    
    if (parameters.size() == 0)
        return utils::tooFewArguments(0, 1);
    else if (parameters.size() > 1)
        return utils::tooManyArguments(parameters.size(), 1);
    
    common::elements::Element *param = parameters[0]->autoConvert(common::bytecodes::ApicaTypeBytecode::String);
    if (param->isErrorOrController())
        return param;
    
    common::values::ValueString *name_val = static_cast<common::values::ValueString*>(param->getValue());
    std::optional<common::elements::Element*> error = utils::shouldNotBeNull(param, "path");
    if (error) {
        delete param;
        return error.value();
    }
    
    LoggerSystem::getInstance().systemLognSuccess("Closed to load a new application");
    this->next_app = name_val->getValue().value();
    delete param;

    this->mode = utils::ApicaMode::APM_Quit;
    return new common::elements::Element(
        common::elements::ElementModifier::Terminate,
        new common::values::ValueNull()
    );
}

void ApicaSystem::forceQuitApp() {
    LoggerSystem::getInstance().systemLognError(std::string(utils::APC_ERROR_FORCE_QUIT));
    this->mode = utils::ApicaMode::APM_QuitFinished;
}

void ApicaSystem::systemLoadApp(const std::string &name) {
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

        if (this->next_app) {
            this->right = utils::ApicaRight::APR_APP;
            this->mode = utils::ApicaMode::APM_Init;
            this->systemLoadApp(this->next_app.value());
            this->next_app = std::nullopt;
        } else {
            if (this->right & utils::ApicaRight::APR_MainMenuRight) {
                this->mode = utils::ApicaMode::APM_SpecialQuit;
            } else {
                this->right = utils::ApicaRight::APR_MAIN_MENU;
                this->mode = utils::ApicaMode::APM_Init;
                this->systemLoadApp(utils::MAIN_MENU_NAME);
            }
        }
    }
}