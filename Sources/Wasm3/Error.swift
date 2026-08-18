//
//  Error.swift
//  Wasm3
//
//  Created by Skitty on 6/18/23.
//

import Foundation
import wasm3_c

public enum Wasm3Error: Error, Equatable {
    case failedAllocation
    case invalidMemoryAccess
    case invalidSignature
    case mismatchedEnvironments
    case missingFunction
    case runtimeDisabled

    // parse errors
    case incompatibleWasmVersion
    case wasmUnderrun

    // link errors
    case functionLookupFailed
    case missingImportedFunction

    // traps
    public enum Trap: Equatable, Sendable {
        case outOfBoundsMemoryAccess
        case divisionByZero
        case integerOverflow
        case integerConversion
        case indirectCallTypeMismatch
        case tableIndexOutOfRange
        case tableElementIsNull
        case exit
        case abort
        case unreachable
        case stackOverflow
    }
    case trap(Trap)

    // fallback
    case wasm3Error(String)

    // swiftlint:disable:next cyclomatic_complexity
    init(ffiResult: M3Result) {
        switch ffiResult {
            case m3Err_incompatibleWasmVersion:
                self = .incompatibleWasmVersion
            case m3Err_wasmUnderrun:
                self = .wasmUnderrun
            case m3Err_functionLookupFailed:
                self = .functionLookupFailed
            case m3Err_functionImportMissing:
                self = .missingImportedFunction

            case m3Err_trapOutOfBoundsMemoryAccess:
                self = .trap(.outOfBoundsMemoryAccess)
            case m3Err_trapDivisionByZero:
                self = .trap(.divisionByZero)
            case m3Err_trapIntegerOverflow:
                self = .trap(.integerOverflow)
            case m3Err_trapIntegerConversion:
                self = .trap(.integerConversion)
            case m3Err_trapIndirectCallTypeMismatch:
                self = .trap(.indirectCallTypeMismatch)
            case m3Err_trapTableIndexOutOfRange:
                self = .trap(.tableIndexOutOfRange)
            case m3Err_trapTableElementIsNull:
                self = .trap(.tableElementIsNull)
            case m3Err_trapExit:
                self = .trap(.exit)
            case m3Err_trapAbort:
                self = .trap(.abort)
            case m3Err_trapUnreachable:
                self = .trap(.unreachable)
            case m3Err_trapStackOverflow:
                self = .trap(.stackOverflow)

            default:
                let string = String(cString: ffiResult)
                if string == "function signature mismatch" {
                    self = .invalidSignature
                } else {
                    self = .wasm3Error(string)
                }
        }
    }

    var isTrap: Bool {
        switch self {
            case .trap: true
            default: false
        }
    }
}

// TODO: traps https://docs.rs/wasm3/0.3.1/src/wasm3/error.rs.html
