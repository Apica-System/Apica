#include "systems/logger.hpp"
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <filesystem>
#include "utils/constants.hpp"
#include "values/string.hpp"
#include "values/null.hpp"

using namespace systems;

LoggerSystem::LoggerSystem()
    : log_file(std::nullopt) {
    this->getActualTime();

    std::filesystem::create_directory(utils::LOG_PATH);
    std::string log_path(utils::LOG_PATH);
    log_path += this->actual_date;
    std::filesystem::create_directory(log_path);
}

LoggerSystem::~LoggerSystem() {
    if (this->log_file)
        fclose(this->log_file.value());
}

LoggerSystem &LoggerSystem::getInstance() {
    static LoggerSystem instance;
    return instance;
}

void LoggerSystem::createLogFileFor(const std::string &app_name) {
    if (this->log_file) {
        fclose(this->log_file.value());
        this->log_file = std::nullopt;
    }

    std::string filepath(utils::LOG_PATH);
    filepath += this->actual_date;
    filepath += '/';
    filepath += app_name;
    filepath += ".log";

    FILE *file = fopen(filepath.c_str(), "wb");
    if (file)
        this->log_file = file;
}

void LoggerSystem::systemLognError(const std::string &message) const {
    std::lock_guard<std::mutex> lock(this->logger_mutex);
    if (this->log_file)
        fprintf(this->log_file.value(), "\x1b[31m%s\x1b[0m\n", message.c_str());
}

void LoggerSystem::systemLognSuccess(const std::string &message) const {
    std::lock_guard<std::mutex> lock(this->logger_mutex);
    if (this->log_file)
        fprintf(this->log_file.value(), "\x1b[32m%s\x1b[0m\n", message.c_str());
}

common::elements::Element *LoggerSystem::logInfo(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[37mINF: ", "\x1b[0m");
}

common::elements::Element *LoggerSystem::lognInfo(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[37mINF: ", "\x1b[0m\n");
}

common::elements::Element *LoggerSystem::logSuccess(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[32mSUC: ", "\x1b[0m");
}

common::elements::Element *LoggerSystem::lognSuccess(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[32mSUC: ", "\x1b[0m\n");
}

common::elements::Element *LoggerSystem::logWarning(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[33mWRN: ", "\x1b[0m");
}

common::elements::Element *LoggerSystem::lognWarning(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[33mWRN: ", "\x1b[0m\n");
}

common::elements::Element *LoggerSystem::logError(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[31mERR: ", "\x1b[0m");
}

common::elements::Element *LoggerSystem::lognError(const std::vector<common::elements::Element*> &parameters) const {
    return this->logParameters(parameters, "\x1b[31mERR: ", "\x1b[0m\n");
}

void LoggerSystem::getActualTime() {
    auto now = std::chrono::system_clock::now();
    std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm tm = *std::localtime(&t);

    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d");
    this->actual_date = oss.str();
}

common::elements::Element *LoggerSystem::logParameters(const std::vector<common::elements::Element*> &parameters, const char *start, const char *end) const {
    std::lock_guard<std::mutex> lock(this->logger_mutex);
    if (this->log_file) {
        fprintf(this->log_file.value(), "%s", start);
        for (common::elements::Element *element : parameters) {
            element->checkAndConvert(common::bytecodes::ApicaTypeBytecode::String);
            if (element->isErrorOrController())
                continue;

            common::values::ValueString *str = static_cast<common::values::ValueString*>(element->getValue());            
            std::string value = str->getValue().value_or("<null>");

            fprintf(this->log_file.value(), "%s", value.c_str());
        }

        fprintf(this->log_file.value(), "%s", end);
        fflush(this->log_file.value());
    }

    return new common::elements::Element(
        common::elements::ElementModifier::None,
        new common::values::ValueNull()
    );
}