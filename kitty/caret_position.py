# 供 Hammerspoon 调用：返回当前 kitty 窗口文字光标的位置。
# kitten @ --to unix:<socket> kitten caret_position.py
# 输出 JSON（单位为点，原点为 OS 窗口内容区左上角）：{"x", "y", "h", "content_h"}
import json


def main(args):
    pass


def handle_result(args, result, target_window_id, boss):
    from kitty.fast_data_types import get_os_window_size

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return ""
    size = get_os_window_size(window.os_window_id)
    if not size:
        return ""

    # geometry / cell 尺寸是帧缓冲像素，换算成点
    sx = size["width"] / size["framebuffer_width"]
    sy = size["height"] / size["framebuffer_height"]
    cell_w = size["cell_width"]
    cell_h = size["cell_height"]
    g = window.geometry
    cursor = window.screen.cursor
    return json.dumps(
        {
            "x": (g.left + cursor.x * cell_w) * sx,
            "y": (g.top + cursor.y * cell_h) * sy,
            "h": cell_h * sy,
            "content_h": size["height"],
        }
    )


handle_result.no_ui = True
