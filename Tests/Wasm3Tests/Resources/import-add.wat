(module
  (import "env" "add" (func $add (param $rhs i32) (param $lhs i32) (result i32)))
  (memory (export "mem") 1)
  (func (export "add_export") (param i32 i32) (result i32)
    local.get 0
    local.get 1
    (call $add)))
