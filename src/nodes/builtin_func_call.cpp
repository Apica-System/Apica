#include "nodes/builtin_func_call.hpp"
#include "values/error.hpp"
#include "systems/logger.hpp"
#include "values/null.hpp"
#include "systems/apica.hpp"

using namespace nodes;

common::elements::Element *destroyParametersAndReturn(const std::vector<common::elements::Element*> &parameters, common::elements::Element *returned) {
    for (common::elements::Element *param : parameters) {
        delete param;
    }

    return returned;
}

NodeBuiltinFuncCall::NodeBuiltinFuncCall(common::bytecodes::ApicaBuiltinFunctionBytecode func_bytecode, const std::vector<Node*> &parameters)
    : func_bytecode(func_bytecode), parameters(parameters) {

}

NodeBuiltinFuncCall::~NodeBuiltinFuncCall() {
    for (Node *param : this->parameters) {
        if (param) delete param;
    }
}

NodeKind NodeBuiltinFuncCall::getKind() const {
    return NodeKind::BuiltinFuncCall;
}

common::elements::Element *NodeBuiltinFuncCall::evaluate(uint8_t modifier) {
    std::vector<common::elements::Element*> parameters;
    for (nodes::Node *param : this->parameters) {
        common::elements::Element *result = param->evaluate(modifier);
        if (result->isErrorOrController())
            return destroyParametersAndReturn(parameters, result);
        
        parameters.push_back(result);
    }

    switch (this->func_bytecode) {
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogInfo:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logInfo(parameters));

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognInfo:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognInfo(parameters));
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogSuccess:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logSuccess(parameters));

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognSuccess:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognSuccess(parameters));
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogWarning:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logWarning(parameters));

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognWarning:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognWarning(parameters));
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogError:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logError(parameters));

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognError:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognError(parameters));

        case common::bytecodes::ApicaBuiltinFunctionBytecode::QuitApp:
            return destroyParametersAndReturn(parameters, systems::ApicaSystem::getInstance().quitApp());

        default: {
            std::string error_details("An undefined builtin func-call was found -> ");
            error_details += this->func_bytecode;

            return destroyParametersAndReturn(parameters, new common::elements::Element(
                common::elements::ElementModifier::Error,
                new common::values::ValueError(
                    "AccessError",
                    error_details
                )
            ));
        }
    }
}

#ifdef __APICA_DEBUG__
void NodeBuiltinFuncCall::show(std::string &indent) const {
    std::cout << indent << "NodeBuiltinFuncCall(func: " << this->func_bytecode << ")\n";
    
    indent.push_back(' ');
    indent.push_back(' ');
    for (Node *param : this->parameters)
        param->show(indent);
    
    indent.pop_back();
    indent.pop_back();
}
#endif