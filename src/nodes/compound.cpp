#include "nodes/compound.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeCompound::NodeCompound(const std::vector<Node*> &nodes)
    : nodes(nodes) {

}

NodeCompound::~NodeCompound() {
    for (Node *node : this->nodes) {
        if (node) delete node;
    }
}

common::elements::Element *NodeCompound::evaluate(uint8_t modifier) {
    for (nodes::Node *node : this->nodes) {
        common::elements::Element *result = node->evaluate(modifier);
        if (result->isErrorOrController())
            return result;
        
        delete result;
    }

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeCompound::show(std::string &indent) const {
    if (indent.empty())
        std::cout << "ROOT\n";
    else
        std::cout << indent << "NodeCompound()\n";
    
    indent.push_back(' ');
    indent.push_back(' ');
    for (Node *node : this->nodes)
        node->show(indent);
    
    indent.pop_back();
    indent.pop_back();
}
#endif