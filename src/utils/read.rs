use std::fs::File;
use std::io::Read;
use apica_common::bytecodes::{ApicaBuiltinFunctionBytecode, ApicaBytecode, ApicaEntrypointBytecode, ApicaSpecificationBytecode, ApicaTypeBytecode};

pub fn read_u8(file: &mut File) -> Option<u8> {
    let mut buffer = [0u8; 1];
    if file.read_exact(&mut buffer).is_err() {
        return None;
    }

    Some(buffer[0])
}

pub fn read_u16(file: &mut File) -> Option<u16> {
    let mut buffer = [0u8; 2];
    if file.read_exact(&mut buffer).is_err() {
        return None;
    }

    Some(u16::from_le_bytes(buffer))
}

pub fn read_u32(file: &mut File) -> Option<u32> {
    let mut buffer = [0u8; 4];
    if file.read_exact(&mut buffer).is_err() {
        return None;
    }

    Some(u32::from_le_bytes(buffer))
}

pub fn read_u64(file: &mut File) -> Option<u64> {
    let mut buffer = [0u8; 8];
    if file.read_exact(&mut buffer).is_err() {
        return None;
    }

    Some(u64::from_le_bytes(buffer))
}

pub fn read_string(file: &mut File) -> Option<String> {
    let mut buffer = vec![];
    loop {
        if let Some(word) = read_u8(file) {
            if word == 0 { break; }
            buffer.push(word);
        } else {
            return None;
        }
    }
    
    Some(String::from_utf8(buffer).unwrap_or(String::from("�")))
}

pub fn read_bytecode(file: &mut File) -> Option<ApicaBytecode> {
    if let Some(word) = read_u64(file) {
        if let Ok(bytecode) = ApicaBytecode::try_from(word) {
            Some(bytecode)
        } else {
            None
        }
    } else {
        None
    }
}

pub fn read_type_bytecode(file: &mut File) -> Option<ApicaTypeBytecode> {
    if let Some(word) = read_u64(file) {
        if let Ok(bytecode) = ApicaTypeBytecode::try_from(word) {
            Some(bytecode)
        } else {
            None
        }
    } else {
        None
    }
}

pub fn read_entry_bytecode(file: &mut File) -> Option<ApicaEntrypointBytecode> {
    if let Some(word) = read_u64(file) {
        if let Ok(bytecode) = ApicaEntrypointBytecode::try_from(word) {
            Some(bytecode)
        } else {
            None
        }
    } else {
        None
    }
}

pub fn read_builtin_func_bytecode(file: &mut File) -> Option<ApicaBuiltinFunctionBytecode> {
    if let Some(word) = read_u64(file) {
        if let Ok(bytecode) = ApicaBuiltinFunctionBytecode::try_from(word) {
            Some(bytecode)
        } else {
            None
        }
    } else {
        None
    }
}

pub fn read_specification_bytecode(file: &mut File) -> Option<ApicaSpecificationBytecode> {
    if let Some(word) = read_u64(file) {
        if let Ok(bytecode) = ApicaSpecificationBytecode::try_from(word) {
            Some(bytecode)
        } else {
            None
        }
    } else {
        None
    }
}