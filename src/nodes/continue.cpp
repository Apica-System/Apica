#include "nodes/continue.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeContinue::NodeContinue() {

}

NodeKind NodeContinue::getKind() const {
    return NodeKind::Continue;
}

common::elements::Element *NodeContinue::evaluate(uint8_t) {
    return new common::elements::Element(
        common::elements::ElementModifier::Continue,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeContinue::show(std::string &indent) const {
    std::cout << indent << "NodeContinue()\n";
}
#endif