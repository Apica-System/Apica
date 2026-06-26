#include "systems/evaluator.hpp"
#include "nodes/compound.hpp"
#include "systems/reader.hpp"
#include "systems/logger.hpp"
#include "utils/errors.hpp"
#include "values/error.hpp"

using namespace systems;

EvaluatorSystem &EvaluatorSystem::getInstance() {
    static EvaluatorSystem instance;
    return instance;
}

void EvaluatorSystem::reset(uint64_t id_count) {
    this->elements.clear();
    this->elements.resize(id_count);
}

bool EvaluatorSystem::evaluate(common::bytecodes::ApicaEntrypointBytecode entry_bytecode) {
    std::optional<nodes::NodeCompound*> entry = systems::ReaderSystem::getInstance().getEntryNode(entry_bytecode);
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
                std::optional<std::string> details = error->getDetails();
                std::string error_message(error->getName().value());
                if (details) {
                    error_message += ": ";
                    error_message += details.value();
                }

                systems::LoggerSystem::getInstance().systemLognError(error_message);
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

void EvaluatorSystem::setElement(uint64_t id, common::elements::Element *element) {
    if (id >= this->elements.size()) {
        std::string error_message(utils::EVL_ERROR_TOO_BIG_ID);
        error_message += std::to_string(id);

        LoggerSystem::getInstance().systemLognError(error_message);
        delete element;
        return;
    }
    
    if (this->elements[id])
        delete this->elements[id];

    this->elements[id] = element;
}

std::optional<common::elements::Element*> EvaluatorSystem::getElement(uint64_t id) {
    if (id >= this->elements.size()) {
        std::string error_message(utils::EVL_ERROR_TOO_BIG_ID);
        error_message += std::to_string(id);

        LoggerSystem::getInstance().systemLognError(error_message);
        return std::nullopt;
    }

    common::elements::Element *element = this->elements[id];
    if (element) return element;

    return std::nullopt;
}

EvaluatorSystem::EvaluatorSystem() {
    
}

EvaluatorSystem::~EvaluatorSystem() {
    for (common::elements::Element *element : this->elements) {
        if (element) delete element;
    }
}