#include "nodes/literal.hpp"
#include "values/null.hpp"

using namespace nodes;

NodeLiteral::NodeLiteral(common::values::Value *value)
    : value(value) {

}

NodeLiteral::~NodeLiteral() {
    if (this->value) delete this->value;
}

common::elements::Element *NodeLiteral::evaluate(uint8_t) {
    std::optional<common::values::Value*> converted = this->value->autoConvert(this->value->getKind());    
    return new common::elements::Element(
        common::elements::ElementModifier::None,
        converted.value()
    );
}

#ifdef __APICA_DEBUG__
void NodeLiteral::show(std::string &indent) const {
    std::cout << indent << "NodeLiteral(val: ";
    this->value->show('\0');
    std::cout << ")\n";
}
#endif