#pragma once

#include "elements.hpp"

namespace nodes {
    class Node {
    public:
        virtual ~Node() {}
        virtual common::elements::Element *evaluate(uint8_t modifier) = 0;

    #ifdef __APICA_DEBUG__
        virtual void show(std::string &indent) const = 0;
    #endif
    protected:
        Node() {}
    };
}