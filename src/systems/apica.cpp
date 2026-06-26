#include "systems/apica.hpp"
#include "systems/logger.hpp"
#include "systems/reader.hpp"
#include "systems/evaluator.hpp"

#include "utils/errors.hpp"
#include "values/u64.hpp"
#include "values/null.hpp"
#include "utils/constants.hpp"

using namespace systems;

ApicaSystem::ApicaSystem()
    : right(utils::ApicaRight::APR_MAIN_MENU), mode(utils::ApicaMode::APM_SpecialInit) {

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

void ApicaSystem::loadApp(const std::string &name) {
    if (!(this->right & utils::ApicaRight::APR_AppRight))
        return;
    
    systems::LoggerSystem::getInstance().createLogFileFor(name);
    systems::ReaderSystem::getInstance().readApp(name);

    std::optional<common::values::Value*> id_count = systems::ReaderSystem::getInstance().getSpecification(common::bytecodes::ApicaSpecificationBytecode::IdCount);
    if (!id_count) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::APC_ERROR_NO_ID_COUNT));
        this->mode = utils::ApicaMode::APM_Quit;
        return;
    }

    common::values::ValueU64 *count = static_cast<common::values::ValueU64*>(id_count.value());
    systems::EvaluatorSystem::getInstance().reset(count->getValue().value());
}

void ApicaSystem::update() {
    switch (this->mode) {
        case utils::ApicaMode::APM_SpecialInit: {
            this->mode = utils::ApicaMode::APM_Init;
            this->loadApp(utils::MAIN_MENU_NAME);
        } break;

        case utils::ApicaMode::APM_Init: {
            systems::EvaluatorSystem::getInstance().evaluate(common::bytecodes::ApicaEntrypointBytecode::Init);
            this->mode = utils::ApicaMode::APM_Update;
        } break;

        case utils::ApicaMode::APM_Update: {
            if (!systems::EvaluatorSystem::getInstance().evaluate(common::bytecodes::ApicaEntrypointBytecode::Update))
                this->mode = utils::ApicaMode::APM_Quit;
        } break;

        case utils::ApicaMode::APM_Quit: {
            systems::EvaluatorSystem::getInstance().evaluate(common::bytecodes::ApicaEntrypointBytecode::Quit);
            if (this->right & utils::ApicaRight::APR_MainMenuRight) {
                this->mode = utils::ApicaMode::APM_SpecialQuit;
            } else {
                this->right = utils::ApicaRight::APR_MAIN_MENU;
                this->mode = utils::ApicaMode::APM_Init;
                this->loadApp(utils::MAIN_MENU_NAME);
            }
        } break;

        default: break;
    }
}