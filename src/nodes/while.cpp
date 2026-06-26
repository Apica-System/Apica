#include "nodes/while.hpp"
#include "systems/evaluator.hpp"
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

NodeKind NodeWhile::getKind() const {
    return NodeKind::While;
}

void recalculateCondition(common::elements::Element *condition, common::elements::Element *body_result, nodes::Node *condition_node) {
    delete body_result;
    delete condition;
    condition = condition_node->evaluate(systems::EvaluatorModifier::EM_None);
}

common::elements::Element *NodeWhile::evaluate(uint8_t modifier) {
    common::elements::Element *condition = this->condition->evaluate(systems::EvaluatorModifier::EM_None);
    condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
    if (condition->isErrorOrController())
        return condition;

    common::values::ValueBool *result = static_cast<common::values::ValueBool*>(condition->getValue());
    while (result->getValue().value()) {
        common::elements::Element *body_result = this->body->evaluate(modifier);
        if (body_result->isErrorOrController()) {
            if (body_result->getModifier() & common::elements::ElementModifier::Break) {
                delete condition;
                delete body_result;
                break;
            } else if (body_result->getModifier() & common::elements::ElementModifier::Continue) {
                recalculateCondition(condition, body_result, this->condition);
                condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
                if (condition->isErrorOrController())
                    return condition;
                continue;
            }

            delete condition;
            return body_result;
        }

        recalculateCondition(condition, body_result, this->condition);
        condition->checkAndConvert(common::bytecodes::ApicaTypeBytecode::Bool);
        if (condition->isErrorOrController())
            return condition;
    }

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