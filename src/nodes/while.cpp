#include "nodes/while.hpp"
#include "VM/evaluator.hpp"
#include "values/bool.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeWhile::NodeWhile(Node *condition, Node *body)
    : condition(condition), body(body) {
}

NodeWhile::~NodeWhile() {
    if (this->condition) delete this->condition;
    if (this->body) delete this->body;
}

common::elements::Element *NodeWhile::evaluate(uint8_t modifier) {
    common::elements::Element *while_condition = this->condition->evaluate(VM::EvaluatorModifier::EM_CopyCall);
    while_condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
    if (while_condition->isErrorOrController())
        return while_condition;

    common::values::ValueBool *result = static_cast<common::values::ValueBool*>(while_condition->getValue());
    while (VM::VMEvaluator::getInstance().isRunning() && result->getValue().value()) {
        common::elements::Element *body_result = this->body->evaluate(modifier);

        if (body_result->isErrorOrController()) {
            uint8_t body_modifier = body_result->getModifier();
            if (body_modifier & common::elements::ElementModifier::Break) {
                delete while_condition;
                delete body_result;
                break;
            }
            
            if (body_modifier & common::elements::ElementModifier::Continue) {
                delete body_result;
                delete while_condition;
                
                while_condition = this->condition->evaluate(VM::EvaluatorModifier::EM_None);
                while_condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
                
                if (while_condition->isErrorOrController()) {
                    return while_condition;
                }
                
                result = static_cast<common::values::ValueBool*>(while_condition->getValue());
                continue;
            }

            delete while_condition;
            return body_result;
        }


        delete body_result;
        delete while_condition;

        while_condition = this->condition->evaluate(VM::EvaluatorModifier::EM_CopyCall);
        while_condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
        if (while_condition->isErrorOrController())
            return while_condition;
        
        result = static_cast<common::values::ValueBool*>(while_condition->getValue());
    }

    delete while_condition;
    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeWhile::show(std::string &indent) const {
    std::cout << indent << "NodeWhile()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->condition->show(indent);
    this->body->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif