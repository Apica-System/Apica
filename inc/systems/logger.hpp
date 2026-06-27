#pragma once

#include <cstdint>
#include <optional>
#include <string>
#include <vector>
#include <mutex>

#include "elements.hpp"

namespace systems {
    class LoggerSystem final {
    public:
        static LoggerSystem &getInstance();

        void createLogFileFor(const std::string &app_name);
        void systemLognError(const std::string &message) const;
        void systemLognSuccess(const std::string &message) const;

        common::elements::Element *logInfo(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *lognInfo(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *logSuccess(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *lognSuccess(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *logWarning(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *lognWarning(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *logError(const std::vector<common::elements::Element*> &parameters) const;
        common::elements::Element *lognError(const std::vector<common::elements::Element*> &parameters) const;
    private:
        std::optional<FILE*> log_file;
        std::string actual_date;
        mutable std::mutex logger_mutex;

        LoggerSystem();
        ~LoggerSystem();

        LoggerSystem(LoggerSystem &other) = delete;
        void operator=(const LoggerSystem &) = delete;

        void getActualTime();

        common::elements::Element *logParameters(const std::vector<common::elements::Element*> &parameters, const char *start, const char *end) const;
    };
}