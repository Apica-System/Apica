#include "nodes/ternary_op.hpp"
#include "systems/evaluator.hpp"
#include "values/bool.hpp"

using namespace nodes;

NodeTernaryOperation::NodeTernaryOperation(Node *condition, Node *true_expr, Node *false_expr)
    : condition(condition), true_expression(true_expr), false_expression(false_expr) {

}

NodeTernaryOperation::~NodeTernaryOperation() {
    if (this->condition) delete this->condition;
    if (this->true_expression) delete this->true_expression;
    if (this->false_expression) delete this->false_expression;
}

NodeKind NodeTernaryOperation::getKind() const {
    return NodeKind::TernaryOperation;
}

common::elements::Element *NodeTernaryOperation::evaluate(uint8_t modifier) {
    common::elements::Element *condition = this->condition->evaluate(systems::EvaluatorModifier::EM_None);
    condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
    if (condition->isErrorOrController())
        return condition;
    
    common::values::ValueBool *condition_result = static_cast<common::values::ValueBool*>(condition->getValue());
    common::elements::Element *result = condition_result->getValue().value()
        ? this->true_expression->evaluate(modifier)
        : this->false_expression->evaluate(modifier);
    
    delete condition;
    return result;
}

#ifdef __APICA_DEBUG__
void NodeTernaryOperation::show(std::string &indent) const {
    std::cout << indent << "NodeTernaryOperation()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->condition->show(indent);
    this->true_expression->show(indent);
    this->false_expression->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif