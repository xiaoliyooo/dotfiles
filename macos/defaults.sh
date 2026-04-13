#!/bin/bash

setup_macos_defaults() {
  # 键重复速率
  defaults write NSGlobalDomain KeyRepeat -int 1

  # 重复触发前的延迟
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # 长按变为连续输入
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # 输入法快捷键
  _hotkey() {
    # id, enabled(true/false), ascii, keycode, modifiers
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
      "<dict><key>enabled</key><${2}/><key>value</key><dict><key>parameters</key><array><integer>${3}</integer><integer>${4}</integer><integer>${5}</integer></array><key>type</key><string>standard</string></dict></dict>"
  }
  _hotkey 60 false 32 49 262144 # 选择上一个输入法 (^Space) — 禁用
  _hotkey 61 true 113 12 262144 # 选择下一个输入法 (^Q) — 启用
  unset -f _hotkey

  # 关闭连按两下空格键插入句号
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # 关闭自动大写字词的首字母
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Finder 默认显示隐藏文件
  defaults write com.apple.finder AppleShowAllFiles -bool true
  killall Finder

  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  echo "✓ macOS 键盘偏好配置完成"
}

setup_macos_defaults
