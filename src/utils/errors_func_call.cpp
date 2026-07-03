#include "utils/errors_func_call.hpp"

#include "values/error_stack_trace.hpp"

common::elements::Element *utils::tooFewArguments(uint64_t current, uint64_t arg_count) {
    std::string error_message("Too few arguments. Passed ");
    error_message += current;
    error_message += " on ";
    error_message += arg_count;
    
    return new common::elements::Element(
        common::elements::ElementModifier::Error,
        new common::values::ValueErrorStackTrace(
            "ArgumentsError",
            error_message
        )
    );
}

common::elements::Element *utils::tooManyArguments(uint64_t current, uint64_t arg_count) {
    std::string error_message("Too many arguments. Passed ");
    error_message += current;
    error_message += " on ";
    error_message += arg_count;

    return new common::elements::Element(
        common::elements::ElementModifier::Error,
        new common::values::ValueErrorStackTrace(
            "ArgumentsError",
            error_message
        )
    );
}

common::elements::Element *utils::assertionFailed(const std::string &message) {
    return new common::elements::Element(
        common::elements::ElementModifier::Error,
        new common::values::ValueErrorStackTrace(
            "AssertionError",
            message
        )
    );
}

common::elements::Element *utils::forbidden() {
    return new common::elements::Element(
        common::elements::ElementModifier::Error,
        new common::values::ValueErrorStackTrace(
            "RightsError",
            "This operation requires elevated privileges"
        )
    );
}

std::optional<common::elements::Element*> utils::noArgumentExpected(const std::vector<common::elements::Element*> &parameters) {
    if (parameters.size())
        return tooManyArguments(parameters.size(), 0);
    return std::nullopt;
}

std::optional<common::elements::Element*> utils::shouldNotBeNull(common::elements::Element *argument, const std::string &name) {
    if (argument->getValue()->isNull()) {
        std::string error_message("Argument named `");
        error_message += name;
        error_message += "` should not be null";

        return new common::elements::Element(
            common::elements::ElementModifier::Error,
            new common::values::ValueErrorStackTrace(
                "ArgumentsError",
                error_message
            )
        );
    }

    return std::nullopt;
}