#!/bin/bash

# VulkanMod Vulkan 1.2 -> 1.1 一键修改脚本
# 请在源码根目录下运行此脚本

echo "======================================"
echo "VulkanMod Vulkan 1.2 -> 1.1 修改脚本"
echo "======================================"
echo ""

# 检查是否在正确的目录
if [ ! -d "src/main/java/net/vulkanmod" ]; then
    echo "错误：请在 VulkanMod 源码根目录下运行此脚本！"
    echo "当前目录应包含 src、gradle 等文件夹"
    exit 1
fi

echo "✓ 目录检查通过"
echo ""

# 定义文件路径
DEVICE_FILE="src/main/java/net/vulkanmod/vulkan/device/Device.java"
SPIRV_FILE="src/main/java/net/vulkanmod/vulkan/shader/SPIRVUtils.java"
VULKAN_FILE="src/main/java/net/vulkanmod/vulkan/Vulkan.java"

# 备份文件
echo "正在备份原文件..."
cp "$DEVICE_FILE" "${DEVICE_FILE}.bak"
cp "$SPIRV_FILE" "${SPIRV_FILE}.bak"
cp "$VULKAN_FILE" "${VULKAN_FILE}.bak"
echo "✓ 备份完成（.bak 文件）"
echo ""

# 修改 1: Device.java - 注释掉 Vulkan 1.2 版本检查
echo "正在修改 Device.java..."
if [ -f "$DEVICE_FILE" ]; then
    # 找到包含 "if (VK_VERSION_MINOR(vkVer1) < 2)" 的行并注释掉整个 if 块
    sed -i '/if (VK_VERSION_MINOR(vkVer1) < 2)/,/throw new RuntimeException/c\
        // Vulkan 1.2 version check disabled\
        // if (VK_VERSION_MINOR(vkVer1) < 2) {\
        //     throw new RuntimeException("Vulkan 1.2 not supported. Only Has: " + formattedVersion); \
        // }' "$DEVICE_FILE"
    
    # 更精确的替换方法
    sed -i 's/if (VK_VERSION_MINOR(vkVer1) < 2)/\/\/ Vulkan 1.2 check disabled: if (VK_VERSION_MINOR(vkVer1) < 2)/g' "$DEVICE_FILE"
    sed -i 's/throw new RuntimeException("Vulkan 1.2 not supported/\/\/ throw new RuntimeException("Vulkan 1.2 not supported/g' "$DEVICE_FILE"
    
    echo "✓ Device.java 修改完成"
else
    echo "✗ 错误：找不到 $DEVICE_FILE"
    exit 1
fi
echo ""

# 修改 2: SPIRVUtils.java - 将 Vulkan 1.2 改为 1.1
echo "正在修改 SPIRVUtils.java..."
if [ -f "$SPIRV_FILE" ]; then
    # 替换 shaderc_target_env_vulkan_1_2 为 1_1
    sed -i 's/shaderc_target_env_vulkan_1_2/shaderc_target_env_vulkan_1_1/g' "$SPIRV_FILE"
    # 替换 VK12.VK_API_VERSION_1_2 为 VK11.VK_API_VERSION_1_1
    sed -i 's/VK12\.VK_API_VERSION_1_2/VK11.VK_API_VERSION_1_1/g' "$SPIRV_FILE"
    
    echo "✓ SPIRVUtils.java 修改完成"
else
    echo "✗ 错误：找不到 $SPIRV_FILE"
    exit 1
fi
echo ""

# 修改 3: Vulkan.java - 多处修改
echo "正在修改 Vulkan.java..."
if [ -f "$VULKAN_FILE" ]; then
    # 替换 import 语句
    sed -i 's/import static org\.lwjgl\.vulkan\.VK12\.VK_API_VERSION_1_2;/import static org.lwjgl.vulkan.VK11.VK_API_VERSION_1_1;/g' "$VULKAN_FILE"
    
    # 替换 apiVersion 调用
    sed -i 's/apiVersion(VK_API_VERSION_1_2)/apiVersion(VK_API_VERSION_1_1)/g' "$VULKAN_FILE"
    
    # 替换其他 VK_API_VERSION_1_2 引用
    sed -i 's/VK_API_VERSION_1_2/VK_API_VERSION_1_1/g' "$VULKAN_FILE"
    
    echo "✓ Vulkan.java 修改完成"
else
    echo "✗ 错误：找不到 $VULKAN_FILE"
    exit 1
fi
echo ""

echo "======================================"
echo "所有修改已完成！"
echo "======================================"
echo ""
echo "修改的文件："
echo "  1. $DEVICE_FILE"
echo "  2. $SPIRV_FILE"
echo "  3. $VULKAN_FILE"
echo ""
echo "备份文件已创建（.bak 后缀）"
echo ""
echo "接下来可以运行 './gradlew build' 进行编译"
echo ""

# 显示修改差异
echo "是否查看修改后的关键代码？(y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo ""
    echo "=== Device.java 中的修改 ==="
    grep -n "Vulkan 1.2" "$DEVICE_FILE" | head -5
    echo ""
    echo "=== SPIRVUtils.java 中的修改 ==="
    grep -n "shaderc_target_env_vulkan_1_1" "$SPIRV_FILE"
    echo ""
    echo "=== Vulkan.java 中的修改 ==="
    grep -n "VK_API_VERSION_1_1" "$VULKAN_FILE"
fi

echo ""
echo "完成！"
