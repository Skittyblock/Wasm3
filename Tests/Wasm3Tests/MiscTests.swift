//
//  MiscTests.swift
//  Wasm3
//
//  Created by skitty on 8/18/26.
//

@testable import Wasm3
import Testing

@Suite
struct MiscTests {
    @Test func safeIntegerConversion() {
        let a: Int64 = .min
        let b = Int64(safe: UInt64(safe: a))
        #expect(a == b)

        let c: UInt64 = .max
        let d = UInt64(safe: Int64(safe: c))
        #expect(c == d)

        let e: Int32 = .min
        let f = Int32(safe: UInt32(safe: e))
        #expect(e == f)

        let g: UInt32 = .max
        let h = UInt32(safe: Int32(safe: g))
        #expect(g == h)
    }
}
