#include "VM/evaluator.hpp"

#include "systems/logger.hpp"
#include "systems/events.hpp"
#include "systems/apica.hpp"
#include "systems/window.hpp"

#include "nodes/compound.hpp"
#include "utils/errors.hpp"

#include "values/error.hpp"
#include "values/u32.hpp"
#include "values/u64.hpp"
#include "values/string.hpp"
#include "values/bool.hpp"

using namespace VM;

VMEvaluator &VMEvaluator::getInstance() {
    static VMEvaluator instance;
    return instance;
}

VMEvaluator::VMEvaluator()
    : running(false) {
    
}

VMEvaluator::~VMEvaluator() {
    this->clear();
}

bool VMEvaluator::readApp(const std::string &app_name) {
    if (!this->reader.readApp(app_name))
        return false;
    
    this->clear();
    std::optional<common::values::Value*> id_count = this->reader.getSpecification(common::bytecodes::ApicaSpecificationBytecode::IdCount);
    if (!id_count) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::EVL_ERROR_NO_ID_COUNT));
        return false;
    }
    
    common::values::ValueU64 *count = static_cast<common::values::ValueU64*>(id_count.value());
    this->elements.resize(count->getValue().value_or(0));

    this->applySpecs(app_name);
    return true;
}

void VMEvaluator::cancel() {
    this->running = false;
}

bool VMEvaluator::isRunning() const {
    return this->running;
}

int SDLCALL VMEvaluator::loop(void*) {
    VMEvaluator &evaluator = VMEvaluator::getInstance();
    evaluator.running = true;

    while (evaluator.running) {
        systems::EventsSystem::getInstance().handleNewTick();
        
        utils::ApicaMode mode = systems::ApicaSystem::getInstance().getMode();
        switch (mode) {
            case utils::APM_Init: {
                evaluator.evaluate(common::bytecodes::ApicaEntrypointBytecode::Init);
            } break;

            case utils::APM_Update: {
                if (!evaluator.evaluate(common::bytecodes::ApicaEntrypointBytecode::Update))
                    systems::ApicaSystem::getInstance().setQuitFinished();
            } break;
            
            case utils::APM_Quit: {
                evaluator.evaluate(common::bytecodes::ApicaEntrypointBytecode::Quit);
                systems::ApicaSystem::getInstance().setQuitFinished();
            } break;

            default: break;
        }
    }

    systems::EventsSystem::getInstance().handleNewTick();
    return 0;
}

void VMEvaluator::setElement(uint64_t id, common::elements::Element *element) {
    if (id >= this->elements.size()) {
        std::string error_message(utils::EVL_ERROR_TOO_BIG_ID);
        error_message += std::to_string(id);

        systems::LoggerSystem::getInstance().systemLognError(error_message);
        delete element;
        return;
    }

    if (this->elements[id])
        delete this->elements[id];
    
    this->elements[id] = element;
}

std::optional<common::elements::Element*> VMEvaluator::getElement(uint64_t id) {
    if (id >= this->elements.size()) {
        std::string error_message(utils::EVL_ERROR_TOO_BIG_ID);
        error_message += std::to_string(id);

        systems::LoggerSystem::getInstance().systemLognError(error_message);
        return std::nullopt;
    }

    common::elements::Element *element = this->elements[id];
    if (element) return element;

    return std::nullopt;
}

void VMEvaluator::clear() {
    for (common::elements::Element *element : this->elements) {
        if (element)
            delete element;
    }

    this->elements.clear();
}

bool VMEvaluator::evaluate(common::bytecodes::ApicaEntrypointBytecode entry_bytecode) {
    std::optional<nodes::NodeCompound*> entry = this->reader.getEntryNode(entry_bytecode);
    if (!entry) {
        std::string error_message(utils::EVL_ERROR_GET_ENTRYPOINT);
        error_message += std::to_string(entry_bytecode);

        systems::LoggerSystem::getInstance().systemLognError(error_message);
        return false;
    }

#ifdef __APICA_DEBUG__
    std::string indent;
    entry.value()->show(indent);
#endif

    common::elements::Element *result = entry.value()->evaluate(EvaluatorModifier::EM_None);
    if (result->isErrorOrController()) {
        switch (result->getModifier()) {
            case common::elements::ElementModifier::Error: {
                common::values::ValueError *error = static_cast<common::values::ValueError*>(result->getValue());
                std::string trace("In entrypoint `");
                if (entry_bytecode == common::bytecodes::ApicaEntrypointBytecode::Init) trace += "init`";
                else if (entry_bytecode == common::bytecodes::ApicaEntrypointBytecode::Update) trace += "update`";
                else trace += "quit`";
                
                error->addTrace(trace);
                systems::LoggerSystem::getInstance().systemLognError(error->getErrorMessage());
            } break;

            case common::elements::ElementModifier::Break:
                systems::LoggerSystem::getInstance().systemLognError(std::string(utils::EVL_ERROR_CORRUPTED_BREAK));
                break;

            case common::elements::ElementModifier::Continue:
                systems::LoggerSystem::getInstance().systemLognError(std::string(utils::EVL_ERROR_CORRUPTED_CONTINUE));
                break;

            case common::elements::ElementModifier::Return:
                systems::LoggerSystem::getInstance().systemLognError(std::string(utils::EVL_ERROR_CORRUPTED_RETURN));
                break;

            default: break;
        }
    }

    delete result;
    return true;
}

void VMEvaluator::applySpecs(const std::string &app_name) {
    std::optional<common::values::Value*> spec = this->reader.getSpecification(common::bytecodes::ApicaSpecificationBytecode::Title);
    std::string title;
    if (spec) {
        common::values::ValueString *title_spec_val = static_cast<common::values::ValueString*>(spec.value());
        title = title_spec_val->getValue().value();
    } else title = app_name;

    int w = 0, h = 0;
    spec = this->reader.getSpecification(common::bytecodes::ApicaSpecificationBytecode::WindowWidth);
    if (spec) {
        common::values::ValueU32 *width_spec_val = static_cast<common::values::ValueU32*>(spec.value());
        w = width_spec_val->getValue().value();
    }

    spec = this->reader.getSpecification(common::bytecodes::ApicaSpecificationBytecode::WindowHeight);
    if (spec) {
        common::values::ValueU32 *height_spec_val = static_cast<common::values::ValueU32*>(spec.value());
        h = height_spec_val->getValue().value();
    }

    systems::WindowSystem::getInstance().systemSetInfos(title, w, h);


    spec = this->reader.getSpecification(common::bytecodes::ApicaSpecificationBytecode::LoggerActivation);
    if (spec) {
        common::values::ValueBool *logger_state = static_cast<common::values::ValueBool*>(spec.value());
        if (!logger_state->getValue().value())
            systems::LoggerSystem::getInstance().closeLogFile();
    }
}