//
//  Wasm3Tests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

// tests taken from wasm3-rs

@Suite
struct Wasm3Tests {
    @Test func testAddUInt32() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "add_u32")
        let result: UInt32 = try fun.call(UInt32(124), UInt32(612))
        #expect(result == 736)
    }

    @Test func testAddUInt64() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "add_u64")
        let result: UInt64 = try fun.call(UInt64(124), UInt64(612))
        #expect(result == 736)
    }

    @Test func testUnaryFunc() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "invert")
        let result: Int64 = try fun.call(Int64(736))
        #expect(result == -737)
    }

    @Test func testNoReturnFunc() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "no_return")
        try fun.call(Int64(736))
    }

    @Test func testNoArgsFunc() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "constant")
        let result: UInt64 = try fun.call()
        #expect(result == 0xDEAD_BEEF_0000_FFFF)
    }

    @Test func testNoArgsUInt32Func() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "u32")
        let result: UInt32 = try fun.call()
        #expect(result == 0xDEAD_BEEF)
    }

    @Test func testNoArgsNoReturnFunc() throws {
        let mod = try module(for: .wasmTestBins)
        let fun = try mod.findFunction(name: "empty")
        try fun.call()
    }

    @Test func testResizeMemory() throws {
        let mod = try module(for: .wasmTestBins)
        try mod.runtime.resizeMemory(numPages: 1)
        let fun = try mod.findFunction(name: "memory_size")
        #expect(try fun.call() == UInt32(1))
        try mod.runtime.resizeMemory(numPages: 5)
        #expect(try fun.call() == UInt32(5))
        try mod.runtime.resizeMemory(numPages: 10)
        #expect(try fun.call() == UInt32(10))
    }
}
