#!/bin/bash

THEMES_DIR="$HOME/.config/waybar/themes"
CURRENT_THEME_FILE="$HOME/.config/waybar/current-theme"

# 确保主题目录存在
mkdir -p "$THEMES_DIR"

# 获取可用的主题列表
themes=()
for theme_file in "$THEMES_DIR"/config-*; do
    if [[ -f "$theme_file" ]]; then
        theme_name=$(basename "$theme_file" | sed 's/^config-//')
        # 检查对应的样式文件是否存在
        if [[ -f "$THEMES_DIR/style-${theme_name}.css" ]]; then
            themes+=("$theme_name")
        fi
    fi
done

# 如果没有找到完整主题，显示错误
if [[ ${#themes[@]} -eq 0 ]]; then
    notify-send "Waybar 主题" "未找到完整的主题文件（需要 config-* 和 style-*.css）" -t 3000
    exit 1
fi

# 显示主题选择
selected=$(printf "%s\n" "${themes[@]}" | wofi --dmenu --prompt "选择 Waybar 主题")

if [[ -n "$selected" ]]; then
    echo "切换到主题: $selected"
    
    # 检查主题文件是否存在
    if [[ ! -f "$THEMES_DIR/config-$selected" ]] || [[ ! -f "$THEMES_DIR/style-$selected.css" ]]; then
        notify-send "Waybar 主题" "主题 '$selected' 文件不完整" -t 3000
        exit 1
    fi
    
    # 杀死所有 waybar 进程
    pkill waybar
    sleep 0.5
    
    # 复制主题文件
    cp "$THEMES_DIR/config-$selected" ~/.config/waybar/config
    cp "$THEMES_DIR/style-$selected.css" ~/.config/waybar/style.css
    
    # 保存当前主题
    echo "$selected" > "$CURRENT_THEME_FILE"
    
    # 重新启动 waybar
    waybar &
    
    # 发送通知
    notify-send "Waybar 主题切换" "已切换到: $selected" -t 2000
    
    echo "主题切换完成: $selected"
fi
