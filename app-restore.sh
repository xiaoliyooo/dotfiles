#!/bin/bash

# mackup restore + 刷新 plist 缓存
# macOS 14+ 的 cfprefsd 会缓存 plist，restore 后需要 defaults import 才能生效

MACKUP_PREFS_DIR="$HOME/dotfiles/mackup/storage/Library/Preferences"

echo "🔄 恢复 mackup 应用配置..."

echo "  暂停运行中的应用..."
for app in "Alfred Preferences" "Alfred" "Moom" "AltTab" "PopClip" "ScreenBrush" "Ice" "Keyboard Maestro Engine" "Keyboard Maestro"; do
  killall "$app" 2>/dev/null
done
sleep 1

mackup restore --force
echo "✓ mackup restore 完成"

# 刷新所有 plist 配置到 cfprefsd 缓存
echo "🔄 刷新 plist 配置..."
for plist in "$MACKUP_PREFS_DIR"/*.plist; do
  [ -f "$plist" ] || continue
  domain=$(basename "$plist" .plist)
  echo "  ↻ defaults import $domain"
  defaults import "$domain" "$plist"
done
echo "✓ plist 配置刷新完成"

echo "🔄 重启相关应用..."

start_app() {
  local app_name="$1"
  echo "  ▶ 启动 $app_name"
  open -a "$app_name"
}

start_app "Alfred 5"
start_app "Moom"
start_app "AltTab"
start_app "PopClip"
start_app "ScreenBrush"
start_app "Ice"
start_app "Keyboard Maestro"

echo "✅ 应用配置恢复完成！"
