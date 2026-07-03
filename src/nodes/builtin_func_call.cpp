#include "nodes/builtin_func_call.hpp"

#include "values/error_stack_trace.hpp"
#include "values/null.hpp"

#include "systems/logger.hpp"
#include "systems/apica.hpp"
#include "systems/events.hpp"
#include "systems/window.hpp"

#include "VM/evaluator.hpp"

using namespace nodes;

common::elements::Element *destroyParametersAndReturn(const std::vector<common::elements::Element*> &parameters, common::elements::Element *returned, const std::string &name) {
    for (common::elements::Element *param : parameters) {
        delete param;
    }

    if (returned->isError() && !name.empty()) {
        std::string trace("In builtin-function `");
        trace += name;
        trace += '`';

        common::values::ValueError *error = static_cast<common::values::ValueError*>(returned->getValue());
        error->addTrace(trace);
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

common::elements::Element *NodeBuiltinFuncCall::evaluate(uint8_t modifier) {
    std::vector<common::elements::Element*> parameters;

    modifier |= VM::EvaluatorModifier::EM_CopyCall;
    for (nodes::Node *param : this->parameters) {
        common::elements::Element *result = param->evaluate(modifier);
        if (result->isErrorOrController())
            return destroyParametersAndReturn(parameters, result, "");
        
        parameters.push_back(result);
    }

    switch (this->func_bytecode) {
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogInfo:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logInfo(parameters), "LogInfo");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognInfo:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognInfo(parameters), "LognInfo");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogSuccess:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logSuccess(parameters), "LogSuccess");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognSuccess:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognSuccess(parameters), "LognSuccess");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogWarning:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logWarning(parameters), "LogWarning");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognWarning:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognWarning(parameters), "LognWarning");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::LogError:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().logError(parameters), "LogError");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LognError:
            return destroyParametersAndReturn(parameters, systems::LoggerSystem::getInstance().lognError(parameters), "LognError");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::LoadApp:
            return destroyParametersAndReturn(parameters, systems::ApicaSystem::getInstance().loadApp(parameters), "LoadApp");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::QuitApp:
            return destroyParametersAndReturn(parameters, systems::ApicaSystem::getInstance().quitApp(parameters), "QuitApp");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::IsKeyPressed:
            return destroyParametersAndReturn(parameters, systems::EventsSystem::getInstance().isKeyPressed(parameters), "IsKeyPressed");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::IsKeyReleased:
            return destroyParametersAndReturn(parameters, systems::EventsSystem::getInstance().isKeyReleased(parameters), "IsKeyReleased");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::IsKeyJustPressed:
            return destroyParametersAndReturn(parameters, systems::EventsSystem::getInstance().isKeyJustPressed(parameters), "IsKeyJustPressed");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::IsKeyJustReleased:
            return destroyParametersAndReturn(parameters, systems::EventsSystem::getInstance().isKeyJustReleased(parameters), "IsKeyJustReleased");

        case common::bytecodes::ApicaBuiltinFunctionBytecode::SetTitle:
            return destroyParametersAndReturn(parameters, systems::WindowSystem::getInstance().setTitle(parameters), "SetTitle");
        
        case common::bytecodes::ApicaBuiltinFunctionBytecode::SetResizable:
            return destroyParametersAndReturn(parameters, systems::WindowSystem::getInstance().setResizable(parameters), "SetResizable");
        
        default: {
            std::string error_details("An undefined builtin func-call was found -> ");
            error_details += std::to_string(this->func_bytecode);

            return destroyParametersAndReturn(parameters, new common::elements::Element(
                common::elements::ElementModifier::Error,
                new common::values::ValueErrorStackTrace(
                    "AccessError",
                    error_details
                )
            ), "");
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