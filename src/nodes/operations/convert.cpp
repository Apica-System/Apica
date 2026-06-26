#include "nodes/operations/convert.hpp"
#include "systems/evaluator.hpp"

using namespace nodes;

NodeConvert::NodeConvert(Node *left, common::bytecodes::ApicaTypeBytecode right)
    : left(left), right(right) {

}

NodeConvert::~NodeConvert() {
    if (this->left) delete this->left;
}

NodeKind NodeConvert::getKind() const {
    return NodeKind::Convert;
}

common::elements::Element *NodeConvert::evaluate(uint8_t modifier) {
    common::elements::Element *left = this->left->evaluate(modifier);
    if (left->isErrorOrController())
        return left;
    
    common::elements::Element *result = left->convert(this->right);
    delete left;
    
    return result;
}

#ifdef __APICA_DEBUG__
void NodeConvert::show(std::string &indent) const {
    std::cout << indent << "NodeConvert(to: " << this->right << ")\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->left->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif