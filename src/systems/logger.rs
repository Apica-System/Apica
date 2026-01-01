use std::fs::{create_dir_all, File};
use std::io::Write;
use apica_common::bytecodes::ApicaTypeBytecode;
use apica_common::element::Element;
use apica_common::values::value::Value;
use chrono::Local;

pub struct LoggerSystem {
    actual_file: Option<File>,
    actual_date: Option<String>
}

impl LoggerSystem {
    pub fn init(activate: bool) -> LoggerSystem {
        let date = if activate {
            let now = Local::now();
            Some(now.format("%Y-%m-%d").to_string())
        } else { None };

        if let Some(actual_date) = &date {
            let dirpath = format!("logs/{actual_date}");
            let _ = create_dir_all(dirpath).is_err();
        }

        LoggerSystem { actual_file: None, actual_date: date }
    }

    pub fn create_file_for(&mut self, app_name: &str) {
        if let Some(actual_date) = &self.actual_date {
            let filepath = format!("logs/{}/{}.log", actual_date, app_name);
            self.actual_file = if let Ok(file) = File::create(filepath) { Some(file) } else { None };
        }
    }

    pub fn system_logn_success(&mut self, message: String) {
        if let Some(file) = &mut self.actual_file {
            let _ = writeln!(file, "\x1b[32mAPC_SUC: {message}\x1b[0m");
        }
    }

    pub fn system_logn_error(&mut self, message: String) {
        if let Some(file) = &mut self.actual_file {
            let _ = writeln!(file, "\x1b[31mAPC_ERR: {message}\x1b[0m");
        }
    }

    pub fn log_info(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[37mINF: ", "\x1b[0m");
    }

    pub fn logn_info(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[37mINF: ", "\x1b[0m\n");
    }

    pub fn log_success(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[32mSUC: ", "\x1b[0m");
    }

    pub fn logn_success(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[32mSUC: ", "\x1b[0m\n");
    }

    pub fn log_warning(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[33mWRN: ", "\x1b[0m");
    }

    pub fn logn_warning(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[33mWRN: ", "\x1b[0m\n");
    }

    pub fn log_error(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[31mERR: ", "\x1b[0m");
    }

    pub fn logn_error(&mut self, parameters: Vec<Element>) {
        self.log_parameters(parameters, "\x1b[31mERR: ", "\x1b[0m\n");
    }

    fn log_parameters(&mut self, parameters: Vec<Element>, start: &str, end: &str) {
        if let Some(file) = &mut self.actual_file {
            let _ = write!(file, "{start}");
            for param in &parameters {
                if let Value::String(parameter) = param.get_value() {
                    let _ = write!(file, "{}", parameter.get_value().as_ref().unwrap_or(&"null".to_string()));
                } else {
                    let converted = param.convert(ApicaTypeBytecode::String);
                    let parameter = match converted.get_value() {
                        Value::String(s) => s,
                        _ => unreachable!(),
                    };

                    let _ = write!(file, "{}", parameter.get_value().as_ref().unwrap_or(&"null".to_string()));
                }
            }

            let _ = write!(file, "{end}");
        }
    }
}