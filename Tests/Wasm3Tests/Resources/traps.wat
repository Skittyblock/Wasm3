(module
  (memory 1)

  (type $returns-i32 (func (result i32)))
  (type $takes-i32 (func (param i32)))

  (func $returns-i32 (type $returns-i32)
    i32.const 42)

  ;; table with index 1 left null
  (table 3 funcref)
  (elem (i32.const 0) $returns-i32)
  (elem (i32.const 2) $returns-i32)

  (func (export "unreachable")
    unreachable)

  (func (export "out_of_bounds_memory")
    i32.const 65536
    i32.load
    drop)

  (func (export "division_by_zero")
    i32.const 1
    i32.const 0
    i32.div_s
    drop)

  (func (export "integer_overflow")
    i32.const -2147483648
    i32.const -1
    i32.div_s
    drop)

  (func (export "integer_conversion")
    f32.const nan
    i32.trunc_f32_s
    drop)

  (func (export "indirect_call_type_mismatch")
    i32.const 0
    i32.const 0
    call_indirect (type $takes-i32))

  (func (export "table_index_out_of_range") (result i32)
    i32.const 3
    call_indirect (type $returns-i32))

  (func (export "table_element_is_null") (result i32)
    i32.const 1
    call_indirect (type $returns-i32))

  (func $stack-overflow
    call $stack-overflow)
  (export "stack_overflow" (func $stack-overflow))
)
