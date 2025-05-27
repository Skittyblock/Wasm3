//
//  yield.c
//  Wasm3
//
//  Created by Skitty on 5/27/25.
//

#import "yield.h"

__thread _Bool should_yield_next = 0;

void set_should_yield_next(void) {
    should_yield_next = 1;
}

M3Result m3_Yield(void) {
    if (should_yield_next) {
        should_yield_next = 0;
        return m3Err_trapAbort;
    } else {
        return m3Err_none;
    }
}
