#!/bin/bash

# 调用 Java 运行 JAR 文件，并传递所有命令行参数
java -jar target/iting-1.0-jar-with-dependencies.jar "$@"

# 等待用户输入，以便不立刻退出
echo "Press Enter to exit..."
read