#include "nodes/blank_return.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeBlankReturn::NodeBlankReturn() {

}

NodeKind NodeBlankReturn::getKind() const {
    return NodeKind::BlankReturn;
}

common::elements::Element *NodeBlankReturn::evaluate(uint8_t) {
    return new common::elements::Element(
        common::elements::ElementModifier::Return,
        new common::values::ValueNull()
    );
}

#ifdef __APICA_DEBUG__
void NodeBlankReturn::show(std::string &indent) const {
    std::cout << indent << "NodeBlankReturn()\n";
}
#endif