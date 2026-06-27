#include "nodes/if.hpp"
#include "values/bool.hpp"
#include "values/null.hpp"
#include "VM/evaluator.hpp"

using namespace nodes;

NodeIf::NodeIf(Node *condition, Node *body)
    : condition(condition), body(body) {

}

NodeIf::~NodeIf() {
    if (this->condition) delete this->condition;
    if (this->body) delete this->body;
}

NodeKind NodeIf::getKind() const {
    return NodeKind::If;
}

common::elements::Element *NodeIf::evaluate(uint8_t modifier) {
    common::elements::Element *condition = this->condition->evaluate(VM::EvaluatorModifier::EM_None);
    condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
    if (condition->isErrorOrController())
        return condition;
    
    common::values::ValueBool *condition_result = static_cast<common::values::ValueBool*>(condition->getValue());
    if (condition_result->getValue().value()) {
        delete condition;
        common::elements::Element *body = this->body->evaluate(modifier);
        if (body->isErrorOrController())
            return body;
    
        delete body;
    }

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeIf::show(std::string &indent) const {
    std::cout << indent << "NodeIf()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->condition->show(indent);
    this->body->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif