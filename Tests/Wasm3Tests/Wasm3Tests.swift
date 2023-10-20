@testable import Wasm3
import XCTest

// tests shamelessly stolen from wasm3-rs
final class Wasm3Tests: XCTestCase {
    private enum TestError: Error {
        case missingResource
    }

    private func wasmTestBins() throws -> [UInt8] {
        guard let url = Bundle.module.url(forResource: "wasm_test_bins", withExtension: "wasm")
        else { throw TestError.missingResource }
        let data = try Data(contentsOf: url)
        return [UInt8](data)
    }

    private func module(bytes: [UInt8]) throws -> Module {
        let env = try Environment()
        let rt = try env.createRuntime(stackSize: 1024 * 60)
        return try rt.parseAndLoadModule(bytes: bytes)
    }

    func testAddUInt32() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "add_u32")
        let result: UInt32 = try fun.call(UInt32(124), UInt32(612))
        XCTAssertEqual(result, 736)
    }

    func testAddUInt64() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "add_u64")
        let result: UInt64 = try fun.call(UInt64(124), UInt64(612))
        XCTAssertEqual(result, 736)
    }

    func testUnaryFunc() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "invert")
        let result: Int64 = try fun.call(Int64(736))
        XCTAssertEqual(result, -737)
    }

    func testNoReturnFunc() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "no_return")
        try fun.call(Int64(736))
    }

    func testNoArgsFunc() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "constant")
        let result: UInt64 = try fun.call()
        XCTAssertEqual(result, 0xDEAD_BEEF_0000_FFFF)
    }

    func testNoArgsUInt32Func() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "u32")
        let result: UInt32 = try fun.call()
        XCTAssertEqual(result, 0xDEAD_BEEF)
    }

    func testNoArgsNoReturnFunc() throws {
        let mod = try module(bytes: wasmTestBins())
        let fun = try mod.findFunction(name: "empty")
        try fun.call()
    }

    func testResizeMemory() throws {
        let mod = try module(bytes: wasmTestBins())
        try mod.runtime.resizeMemory(numPages: 1)
        let fun = try mod.findFunction(name: "memory_size")
        XCTAssertEqual(try fun.call(), UInt32(1))
        try mod.runtime.resizeMemory(numPages: 5)
        XCTAssertEqual(try fun.call(), UInt32(5))
        try mod.runtime.resizeMemory(numPages: 10)
        XCTAssertEqual(try fun.call(), UInt32(10))
    }
}

// test linking
extension Wasm3Tests {
    private func importAddBytes() -> [UInt8] {
        // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/import-add.wat
        let base64 = "AGFzbQEAAAABBwFgAn9/AX8CCwEDZW52A2FkZAAAAwIBAAUDAQABBxQCA21lbQIACmFkZF9leHBvcnQAAQoKAQgAIAAgARAACw=="
        let data = Data(base64Encoded: base64)!
        return [UInt8](data)
    }

    private func add(a: Int32, b: Int32) -> Int32 {
        a + b
    }

    func testLinkFunction() throws {
        let mod = try module(bytes: importAddBytes())
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(Int32(124), Int32(612))
        XCTAssertEqual(result, 736)
    }

    func testLinkClosure() throws {
        let mod = try module(bytes: importAddBytes())
        let add: (Int32, Int32) -> Int32 = { a, b in
            a + b
        }
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(Int32(124), Int32(612))
        XCTAssertEqual(result, 736)
    }

    func testLinkClosureWithMemory() throws {
        let mod = try module(bytes: importAddBytes())
        let add: (Memory, Int32, Int32) -> Int32 = { mem, a, b in
            do {
                try mem.write(bytes: [3], offset: 0)
                let result = try mem.readBytes(offset: 0, length: 1)
                XCTAssertEqual(result[0], 3)
            } catch {
                XCTFail(error.localizedDescription)
            }
            return a + b
        }
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(124, 612)
        XCTAssertEqual(result, 736)
    }
}

// test errors
extension Wasm3Tests {
    func testImportMissing() throws {
        let mod = try module(bytes: importAddBytes())
        XCTAssertThrowsError(try mod.findFunction(name: "add_export")) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.missingImportedFunction)
        }
    }

    func testImportInvalidSignature() throws {
        let mod = try module(bytes: importAddBytes())
        XCTAssertThrowsError(try mod.linkFunction(
            name: "add",
            namespace: "env",
            function: {}
        )) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.invalidSignature)
        }
    }

    func testImportLookupFail() throws {
        let mod = try module(bytes: importAddBytes())
        XCTAssertThrowsError(try mod.linkFunction(
            name: "invalid",
            namespace: "env",
            function: {}
        )) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.functionLookupFailed)
        }
        XCTAssertThrowsError(try mod.linkFunction(
            name: "add",
            namespace: "invalid",
            function: {}
        )) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.functionLookupFailed)
        }
    }

    func testLookupFail() throws {
        let mod = try module(bytes: importAddBytes())
        XCTAssertThrowsError(try mod.findFunction(name: "missing")) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.functionLookupFailed)
        }
    }

    func testWasmParseErrors() throws {
        let env = try Environment()
        // empty byte array
        XCTAssertThrowsError(try Module.parse(env: env, bytes: [])) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.wasmUnderrun)
        }

        // working empty module
        var emptyModule: [UInt8] = [0, 97, 115, 109, 1, 0, 0, 0, 0, 8, 4, 110, 97, 109, 101, 2, 1, 0]
        _ = try Module.parse(env: env, bytes: emptyModule)

        // wasm version 2
        emptyModule[4] = 2
        XCTAssertThrowsError(try Module.parse(env: env, bytes: emptyModule)) { error in
            XCTAssertEqual(error as! Wasm3Error, Wasm3Error.incompatibleWasmVersion)
        }
    }
}

// test memory
extension Wasm3Tests {
    private func fillBytes() -> [UInt8] {
        // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/fill.wat
        let base64 = "AGFzbQEAAAABBwFgA39/fwADAgEABQMBAAEHDgIDbWVtAgAEZmlsbAAACg0BCwAgACABIAL8CwALAAoEbmFtZQIDAQAA"
        let data = Data(base64Encoded: base64)!
        return [UInt8](data)
    }

    func testMemoryFill() throws {
        let mod = try module(bytes: fillBytes())
        let fun = try mod.findFunction(name: "fill")
        try fun.call(0, 13, 5)
        try fun.call(10, 77, 7)
        try fun.call(20, 255, 1000)
        let memory = try mod.runtime.memory()
        XCTAssertEqual(try memory.readBytes(offset: 0, length: 5), Array(repeating: 13, count: 5))
        XCTAssertEqual(try memory.readBytes(offset: 5, length: 5), Array(repeating: 0, count: 5))
        XCTAssertEqual(try memory.readBytes(offset: 10, length: 7), Array(repeating: 77, count: 7))
        XCTAssertEqual(try memory.readBytes(offset: 17, length: 3), Array(repeating: 0, count: 3))
        XCTAssertEqual(try memory.readBytes(offset: 20, length: 10), Array(repeating: 255, count: 10))
        XCTAssertEqual(try memory.readBytes(offset: 970, length: 10), Array(repeating: 255, count: 10))
    }
}

// test globals
extension Wasm3Tests {
    private func globalBytes() -> [UInt8] {
        // wat2wasm -o >(base64) Tests/Wasm3Tests/Resources/global.wat
        let base64 = "AGFzbQEAAAABBAFgAAACCgEDZW52AWcDfwEDAgEABwUBAWYAAAoJAQcAQeQAJAALAAoEbmFtZQIDAQAA"
        let data = Data(base64Encoded: base64)!
        return [UInt8](data)
    }

    func testGlobal() throws {
        let mod = try module(bytes: globalBytes())
        let global = try XCTUnwrap(mod.findGlobal(name: "g", type: Int32.self))
        XCTAssertEqual(try global.value(), 0)

        let fun = try mod.findFunction(name: "f")
        try fun.call()

        let global2 = try XCTUnwrap(mod.findGlobal(name: "g", type: Int32.self))
        XCTAssertEqual(try global2.value(), 100)

        try global2.set(-1)

        let global3 = try XCTUnwrap(mod.findGlobal(name: "g", type: Int32.self))
        XCTAssertEqual(try global3.value(), -1)
    }
}

// test integer conversion
extension Wasm3Tests {
    func testSafeIntegerConversion() {
        let a: Int64 = .min
        let b = Int64(safe: UInt64(safe: a))
        XCTAssertEqual(a, b)

        let c: UInt64 = .max
        let d = UInt64(safe: Int64(safe: c))
        XCTAssertEqual(c, d)

        let e: Int32 = .min
        let f = Int32(safe: UInt32(safe: e))
        XCTAssertEqual(e, f)

        let g: UInt32 = .max
        let h = UInt32(safe: Int32(safe: g))
        XCTAssertEqual(g, h)
    }
}
