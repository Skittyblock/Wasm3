//
//  GlobalTests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

@Suite
struct GlobalTests {
    @Test func globalModification() throws {
        let mod = try module(for: .global)
        let global = try #require(mod.findGlobal(name: "g", type: Int32.self))
        #expect(try global.value() == 0)

        let fun = try mod.findFunction(name: "f")
        try fun.call()

        let global2 = try #require(mod.findGlobal(name: "g", type: Int32.self))
        #expect(try global2.value() == 100)

        try global2.set(-1)

        let global3 = try #require(mod.findGlobal(name: "g", type: Int32.self))
        #expect(try global3.value() == -1)
    }
}
