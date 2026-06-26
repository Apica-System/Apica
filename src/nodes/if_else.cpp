#include "nodes/if_else.hpp"
#include "systems/evaluator.hpp"
#include "values/bool.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeIfElse::NodeIfElse(Node *condition, Node *if_body, Node *else_body)
    : condition(condition), if_body(if_body), else_body(else_body) {

}

NodeIfElse::~NodeIfElse() {
    if (this->condition) delete this->condition;
    if (this->if_body) delete this->if_body;
    if (this->else_body) delete this->else_body;
}

NodeKind NodeIfElse::getKind() const {
    return NodeKind::IfElse;
}

common::elements::Element *NodeIfElse::evaluate(uint8_t modifier) {
    common::elements::Element *condition = this->condition->evaluate(systems::EvaluatorModifier::EM_None);
    condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
    if (condition->isErrorOrController())
        return condition;
    
    common::values::ValueBool *condition_result = static_cast<common::values::ValueBool*>(condition->getValue());
    if (condition_result->getValue().value()) {
        delete condition;
        common::elements::Element *if_body = this->if_body->evaluate(modifier);
        if (if_body->isErrorOrController())
            return if_body;

        delete if_body;
    } else {
        delete condition;
        common::elements::Element *else_body = this->else_body->evaluate(modifier);
        if (else_body->isErrorOrController())
            return else_body;
        
        delete else_body;
    }

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeIfElse::show(std::string &indent) const {
    std::cout << indent << "NodeIfElse()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->condition->show(indent);
    this->if_body->show(indent);
    this->else_body->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif