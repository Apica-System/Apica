#include "nodes/operations/not.hpp"

using namespace nodes;

NodeNot::NodeNot(Node *operand)
    : operand(operand) {

}

NodeNot::~NodeNot() {
    if (this->operand) delete this->operand;
}

common::elements::Element *NodeNot::evaluate(uint8_t modifier) {
    common::elements::Element *operand = this->operand->evaluate(modifier);
    if (operand->isErrorOrController())
        return operand;
    
    common::elements::Element *result = operand->unaryNot();
    delete operand;

    return result;
}

#ifdef __APICA_DEBUG__
void NodeNot::show(std::string &indent) const {
    std::cout << indent << "NodeNot()\n";
    
    indent.push_back(' ');
    indent.push_back(' ');
    this->operand->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif