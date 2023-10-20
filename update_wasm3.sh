rm -rf Sources/wasm3-c/*.c
rm -rf Sources/wasm3-c/include/*
mkdir Sources/wasm3-c/include
git clone git@github.com:wasm3/wasm3.git
mv wasm3/source/*.c Sources/wasm3-c/
mv wasm3/source/*.h Sources/wasm3-c/include/
mv wasm3/source/extra/ Sources/wasm3-c/include/
sed -i '' '/Opcodes should only/d' Sources/wasm3-c/include/m3_exec.h
rm -rf wasm3
