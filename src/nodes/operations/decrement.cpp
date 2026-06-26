#include "nodes/operations/decrement.hpp"
#include "systems/evaluator.hpp"
#include "values/error.hpp"

using namespace nodes;

NodeDecrement::NodeDecrement(Node *operand)
    : operand(operand) {

}

NodeDecrement::~NodeDecrement() {
    if (this->operand) delete this->operand;
}

NodeKind NodeDecrement::getKind() const {
    return NodeKind::Decrement;
}

common::elements::Element *NodeDecrement::evaluate(uint8_t modifier) {
    common::elements::Element *operand = this->operand->evaluate(modifier & ~systems::EvaluatorModifier::EM_CopyCall);
    if (operand->isErrorOrController())
        return operand;
    
    if (operand->getModifier() & common::elements::ElementModifier::Const) {
        delete operand;
        return new common::elements::Element(
            common::elements::ElementModifier::Error,
            new common::values::ValueError(
                "ConstError",
                "Cannot perform a `right ++` unary operation with a constant"
            )
        );
    }

    common::elements::Element *result = operand->decrement();
    delete operand;

    return result;
}

#ifdef __APICA_DEBUG__
void NodeDecrement::show(std::string &indent) const {
    std::cout << indent << "NodeDecrement()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->operand->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif