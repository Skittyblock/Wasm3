//
//  WasmTestSupport.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

import Foundation
import Wasm3

enum TestError: Error {
    case missingResource
}

enum TestResource {
    case fill
    case global
    case importAdd
    case traps
    case wasmTestBins
}

func module(for resource: TestResource) throws -> Module {
    let bytes: [UInt8] = try {
        let base64: String
        switch resource {
            case .wasmTestBins:
                // https://github.com/wasm3/wasm3-rs/tree/master/tests/wasm_test_bins
                guard let url = Bundle.module.url(forResource: "wasm_test_bins", withExtension: "wasm")
                else { throw TestError.missingResource }
                let data = try Data(contentsOf: url)
                return [UInt8](data)
            case .fill:
                // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/fill.wat
                base64 = "AGFzbQEAAAABBwFgA39/fwADAgEABQMBAAEHDgIDbWVtAgAEZmlsbAAACg0BCwAgACABIAL8CwALAAoEbmFtZQIDAQAA"
            case .global:
                // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/global.wat
                base64 = "AGFzbQEAAAABBAFgAAACCgEDZW52AWcDfwEDAgEABwUBAWYAAAoJAQcAQeQAJAALAAoEbmFtZQIDAQAA"
            case .importAdd:
                // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/import-add.wat
                base64 = "AGFzbQEAAAABBwFgAn9/AX8CCwEDZW52A2FkZAAAAwIBAAUDAQABBxQCA21lbQIACmFkZF9leHBvcnQAAQoKAQgAIAAgARAACw=="
            case .traps:
                // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/traps.wat
                base64 = "AGFzbQEAAAABDANgAAF/YAF/AGAAAAMLCgACAgICAgIAAAIEBAFwAAMFAwEAAQfDAQkLdW5yZWFjaGFibGUAARRvdXRfb2ZfYm91bmRzX21lbW9yeQACEGRpdmlzaW9uX2J5X3plcm8AAxBpbnRlZ2VyX292ZXJmbG93AAQSaW50ZWdlcl9jb252ZXJzaW9uAAUbaW5kaXJlY3RfY2FsbF90eXBlX21pc21hdGNoAAYYdGFibGVfaW5kZXhfb3V0X29mX3JhbmdlAAcVdGFibGVfZWxlbWVudF9pc19udWxsAAgOc3RhY2tfb3ZlcmZsb3cACQkNAgBBAAsBAABBAgsBAApUCgQAQSoLAwAACwoAQYCABCgCABoLCABBAUEAbRoLDABBgICAgHhBf20aCwkAQwAAwH+oGgsJAEEAQQARAQALBwBBAxEAAAsHAEEBEQAACwQAEAkL"
        }
        let data = Data(base64Encoded: base64)!
        return [UInt8](data)
    }()
    let env = try Environment()
    let rt = try env.createRuntime(stackSize: 1024 * 60)
    return try rt.parseAndLoadModule(bytes: bytes)
}
