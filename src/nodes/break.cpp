#include "nodes/break.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeBreak::NodeBreak() {

}

NodeKind NodeBreak::getKind() const {
    return NodeKind::Break;
}

common::elements::Element *NodeBreak::evaluate(uint8_t) {
    return new common::elements::Element(
        common::elements::ElementModifier::Break,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeBreak::show(std::string &indent) const {
    std::cout << indent << "NodeBreak()\n";
}
#endif