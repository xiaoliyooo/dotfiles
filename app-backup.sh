#!/bin/bash

# 备份应用配置到 ~/dotfiles/mackup/

echo "🔄 备份应用配置..."
mackup backup --force
echo "✅ 备份完成！"
