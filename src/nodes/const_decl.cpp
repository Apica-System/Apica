#include "nodes/const_decl.hpp"
#include "VM/evaluator.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeConstDeclaration::NodeConstDeclaration(uint64_t id, common::bytecodes::ApicaTypeBytecode type, Node *expression)
    : id(id), value_type(type), expression(expression) {

}

NodeConstDeclaration::~NodeConstDeclaration() {
    if (this->expression) delete this->expression;
}

common::elements::Element *NodeConstDeclaration::evaluate(uint8_t) {
    common::elements::Element *result = this->expression->evaluate(VM::EvaluatorModifier::EM_CopyCall);
    result->checkAndConvert(this->value_type);
    if (result->isErrorOrController())
        return result;

    result->addModifier(common::elements::ElementModifier::Const);
    VM::VMEvaluator::getInstance().setElement(this->id, result);

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeConstDeclaration::show(std::string &indent) const {
    std::cout << indent << "NodeConstDeclaration(id: " << this->id << ", type: " << this->value_type << ")\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->expression->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif