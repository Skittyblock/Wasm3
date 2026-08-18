//
//  MemoryTests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

@Suite
struct MemoryTests {
    @Test func memoryFill() throws {
        let mod = try module(for: .fill)
        let fun = try mod.findFunction(name: "fill")
        try fun.call(0, 13, 5)
        try fun.call(10, 77, 7)
        try fun.call(20, 255, 1000)
        let memory = try mod.runtime.memory()
        #expect(try memory.readBytes(offset: 0, length: 5) == Array(repeating: 13, count: 5))
        #expect(try memory.readBytes(offset: 5, length: 5) == Array(repeating: 0, count: 5))
        #expect(try memory.readBytes(offset: 10, length: 7) == Array(repeating: 77, count: 7))
        #expect(try memory.readBytes(offset: 17, length: 3) == Array(repeating: 0, count: 3))
        #expect(try memory.readBytes(offset: 20, length: 10) == Array(repeating: 255, count: 10))
        #expect(try memory.readBytes(offset: 970, length: 10) == Array(repeating: 255, count: 10))
    }
}
