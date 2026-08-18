//
//  ErrorTests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

@Suite
struct ErrorTests {
    @Test func importMissing() throws {
        let mod = try module(for: .importAdd)
        #expect(throws: Wasm3Error.missingImportedFunction) {
            try mod.findFunction(name: "add_export")
        }
    }

    @Test func importInvalidSignature() throws {
        let mod = try module(for: .importAdd)
        #expect(throws: Wasm3Error.invalidSignature) {
            try mod.linkFunction(
                name: "add",
                namespace: "env",
                function: {}
            )
        }
    }

    @Test func importLookupFail() throws {
        let mod = try module(for: .importAdd)
        #expect(throws: Wasm3Error.functionLookupFailed) {
            try mod.linkFunction(
                name: "invalid",
                namespace: "env",
                function: {}
            )
        }
        #expect(throws: Wasm3Error.functionLookupFailed) {
            try mod.linkFunction(
                name: "add",
                namespace: "invalid",
                function: {}
            )
        }
    }

    @Test func lookupFail() throws {
        let mod = try module(for: .importAdd)
        #expect(throws: Wasm3Error.functionLookupFailed) {
            try mod.findFunction(name: "missing")
        }
    }

    @Test func wasmParseErrors() throws {
        let env = try Environment()
        // empty byte array
        #expect(throws: Wasm3Error.wasmUnderrun) {
            try Module.parse(env: env, bytes: [])
        }

        // working empty module
        var emptyModule: [UInt8] = [0, 97, 115, 109, 1, 0, 0, 0, 0, 8, 4, 110, 97, 109, 101, 2, 1, 0]
        _ = try Module.parse(env: env, bytes: emptyModule)

        // wasm version 2
        emptyModule[4] = 2
        #expect(throws: Wasm3Error.incompatibleWasmVersion) {
            try Module.parse(env: env, bytes: emptyModule)
        }
    }

    @Test(arguments: [
        ("unreachable", Wasm3Error.Trap.unreachable),
        ("out_of_bounds_memory", Wasm3Error.Trap.outOfBoundsMemoryAccess),
        ("division_by_zero", Wasm3Error.Trap.divisionByZero),
        ("integer_overflow", Wasm3Error.Trap.integerOverflow),
        ("integer_conversion", Wasm3Error.Trap.integerConversion),
        ("indirect_call_type_mismatch", Wasm3Error.Trap.indirectCallTypeMismatch),
        ("table_index_out_of_range", Wasm3Error.Trap.tableIndexOutOfRange),
        ("table_element_is_null", Wasm3Error.Trap.tableElementIsNull),
        ("stack_overflow", Wasm3Error.Trap.stackOverflow)
    ])
    func traps(functionName: String, trap: Wasm3Error.Trap) throws {
        let mod = try module(for: .traps)
        let fun = try mod.findFunction(name: functionName)
        #expect(throws: Wasm3Error.trap(trap)) { try fun.call() }
        #expect(throws: Wasm3Error.runtimeDisabled) { try fun.call() }
    }
}
