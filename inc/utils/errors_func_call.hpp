#pragma once

#include "elements.hpp"
#include <vector>

namespace utils {
    common::elements::Element *tooFewArguments(uint64_t current, uint64_t arg_count);
    common::elements::Element *tooManyArguments(uint64_t current, uint64_t arg_count);
    common::elements::Element *assertionFailed(const std::string &message);
    common::elements::Element *forbidden();
    std::optional<common::elements::Element*> noArgumentExpected(const std::vector<common::elements::Element*> &parameters);
    std::optional<common::elements::Element*> shouldNotBeNull(common::elements::Element *argument, const std::string &name);
}