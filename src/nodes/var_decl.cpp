#include "nodes/var_decl.hpp"
#include "systems/evaluator.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeVarDeclaration::NodeVarDeclaration(uint64_t id, common::bytecodes::ApicaTypeBytecode type, Node *expression)
    : id(id), value_type(type), expression(expression) {

}

NodeVarDeclaration::~NodeVarDeclaration() {
    if (this->expression) delete this->expression;
}

NodeKind NodeVarDeclaration::getKind() const {
    return NodeKind::VarDeclaration;
}

common::elements::Element *NodeVarDeclaration::evaluate(uint8_t) {
    common::elements::Element *result = this->expression->evaluate(systems::EvaluatorModifier::EM_CopyCall);
    result->checkAndConvert(this->value_type);
    if (result->isErrorOrController())
        return result;

    result->removeModifier(common::elements::ElementModifier::Const);
    systems::EvaluatorSystem::getInstance().setElement(this->id, result);

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeVarDeclaration::show(std::string &indent) const {
    std::cout << indent << "NodeVarDeclaration(id: " << this->id << ", type: " << this->value_type << ")\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->expression->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif