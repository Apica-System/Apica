#include "nodes/operations/subtract.hpp"

using namespace nodes;

NodeSubtract::NodeSubtract(Node *left, Node *right)
    : left(left), right(right) {

}

NodeSubtract::~NodeSubtract() {
    if (this->left) delete this->left;
    if (this->right) delete this->right;
}

NodeKind NodeSubtract::getKind() const {
    return NodeKind::Subtract;
}

common::elements::Element *NodeSubtract::evaluate(uint8_t modifier) {
    common::elements::Element *left = this->left->evaluate(modifier);
    if (left->isErrorOrController())
        return left;
    
    common::elements::Element *right = this->right->evaluate(modifier);
    if (right->isErrorOrController()) {
        delete left;
        return right;
    }
    
    common::elements::Element *result = left->subtract(right);
    delete left;
    delete right;

    return result;
}

#ifdef __APICA_DEBUG__
void NodeSubtract::show(std::string &indent) const {
    std::cout << indent << "NodeSubtract()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->left->show(indent);
    this->right->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif