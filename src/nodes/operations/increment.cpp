#include "nodes/operations/increment.hpp"
#include "VM/evaluator.hpp"
#include "values/error.hpp"

using namespace nodes;

NodeIncrement::NodeIncrement(Node *operand)
    : operand(operand) {

}

NodeIncrement::~NodeIncrement() {
    if (this->operand) delete this->operand;
}

common::elements::Element *NodeIncrement::evaluate(uint8_t modifier) {
    common::elements::Element *operand = this->operand->evaluate(modifier & ~VM::EvaluatorModifier::EM_CopyCall);
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

    common::elements::Element *result = operand->increment();
    delete operand;
    
    return result;
}

#ifdef __APICA_DEBUG__
void NodeIncrement::show(std::string &indent) const {
    std::cout << indent << "NodeIncrement()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->operand->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif