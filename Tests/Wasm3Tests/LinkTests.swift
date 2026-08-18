//
//  LinkTests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

@Suite
struct LinkTests {
    private func add(a: Int32, b: Int32) -> Int32 {
        a + b
    }

    @Test func linkFunction() throws {
        let mod = try module(for: .importAdd)
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(Int32(124), Int32(612))
        #expect(result == 736)
    }

    @Test func linkClosure() throws {
        let mod = try module(for: .importAdd)
        let add: (Int32, Int32) -> Int32 = { a, b in
            a + b
        }
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(Int32(124), Int32(612))
        #expect(result == 736)
    }

    @Test func linkClosureWithMemory() throws {
        let mod = try module(for: .importAdd)
        let add: (Memory, Int32, Int32) -> Int32 = { mem, a, b in
            do {
                try mem.write(bytes: [3], offset: 0)
                let result = try mem.readBytes(offset: 0, length: 1)
                #expect(result[0] == 3)
            } catch {
                fatalError(error.localizedDescription)
            }
            return a + b
        }
        try mod.linkFunction(name: "add", namespace: "env", function: add)
        let fun = try mod.findFunction(name: "add_export")
        let result: Int32 = try fun.call(124, 612)
        #expect(result == 736)
    }
}
