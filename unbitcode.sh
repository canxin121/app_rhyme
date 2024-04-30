#!/bin/bash

# 定义框架目录
FRAMEWORK_DIR="./build/ios/iphoneos/Runner.app/Frameworks"

# 遍历所有的.framework文件夹
for framework in "$FRAMEWORK_DIR"/*.framework; do
    # 获取文件夹名称
    name=$(basename "$framework" .framework)
    # 检查文件是否存在
    if [ -f "$framework/$name" ]; then
        # 执行bitcode_strip命令
        xcrun bitcode_strip "$framework/$name" -r -o "$framework/$name"
    else
        echo "文件不存在: $framework/$name"
    fi
done

# 遍历所有的.dylib文件
for dylib in "$FRAMEWORK_DIR"/*.dylib; do
    # 检查文件是否存在
    if [ -f "$dylib" ]; then
        # 执行bitcode_strip命令
        xcrun bitcode_strip "$dylib" -r -o "$dylib"
    else
        echo "文件不存在: $dylib"
    fi
done
