#include "nodes/operations/greater_equals.hpp"

using namespace nodes;

NodeGreaterEquals::NodeGreaterEquals(Node *left, Node *right)
    : left(left), right(right) {

}

NodeGreaterEquals::~NodeGreaterEquals() {
    if (this->left) delete this->left;
    if (this->right) delete this->right;
}

common::elements::Element *NodeGreaterEquals::evaluate(uint8_t modifier) {
    common::elements::Element *left = this->left->evaluate(modifier);
    if (left->isErrorOrController())
        return left;
    
    common::elements::Element *right = this->right->evaluate(modifier);
    if (right->isErrorOrController()) {
        delete left;
        return right;
    }
    
    common::elements::Element *result = left->greaterOrEquals(right);
    delete left;
    delete right;

    return result;
}

#ifdef __APICA_DEBUG__
void NodeGreaterEquals::show(std::string &indent) const {
    std::cout << indent << "NodeGreaterEquals()\n";

    indent.push_back(' ');
    indent.push_back(' ');
    this->left->show(indent);
    this->right->show(indent);

    indent.pop_back();
    indent.pop_back();
}
#endif