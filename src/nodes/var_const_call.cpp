#include "nodes/var_const_call.hpp"
#include "VM/evaluator.hpp"
#include "values/error.hpp"

using namespace nodes;

NodeVarConstCall::NodeVarConstCall(uint64_t id)
    : id(id) {

}

common::elements::Element *NodeVarConstCall::evaluate(uint8_t modifier) {
    std::optional<common::elements::Element*> element = VM::VMEvaluator::getInstance().getElement(this->id);
    if (!element) {
        return new common::elements::Element(
            common::elements::ElementModifier::Error,
            new common::values::ValueError(
                "AccessError",
                "A call to an undefined variable or constant was found"
            )
        );
    }

    common::elements::Element *result = element.value();
    if (modifier & VM::EvaluatorModifier::EM_CopyCall) {
        result = result->autoConvert(result->getValue()->getKind());
    } else {
        result = new common::elements::Element(
            common::elements::ElementModifier::Copy | result->getModifier(),
            result->getValue()
        );
    }

    return result;
}

#ifdef __APICA_DEBUG__
void NodeVarConstCall::show(std::string &indent) const {
    std::cout << indent << "NodeVarConstCall(id: " << this->id << ")\n";
}
#endif