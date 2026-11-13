-- 在 kitty 的文字光标下方显示一个短暂的提示框。其他 App 不显示。
--
-- kitty 不通过辅助功能暴露光标，所以用 kitty 远程控制运行自定义 kitten（kitty/caret_position.py）
-- 读取光标所在格子。依赖 kitty.conf 里的 allow_remote_control yes 和
-- listen_on unix:/tmp/locator_vim_kitty--（kitty 会在 socket 路径后追加 -<pid>）。
local M = {}

local KITTY_BUNDLE_ID = "net.kovidgoyal.kitty"
local KITTY_SOCKET_PREFIX = "/tmp/locator_vim_kitty--"

local DISPLAY_SECONDS = 0.8
local FADE_SECONDS = 0.15
local GAP = 4

local style = {
	background = { alpha = 0.96, red = 0.16, green = 0.45, blue = 0.92 }, -- 蓝色
	text = { white = 1, alpha = 1 },
	textSize = 15,
	horizontalPadding = 10,
	verticalPadding = 5,
	radius = 7,
}

local canvas
local hideTimer

local function screenFrameAt(point)
	for _, screen in ipairs(hs.screen.allScreens()) do
		local f = screen:frame()
		if point.x >= f.x and point.x <= f.x + f.w and point.y >= f.y and point.y <= f.y + f.h then
			return f
		end
	end
	return hs.screen.mainScreen():frame()
end

-- 在切换输入法之前调用：macism 会短暂激活临时窗口，切换后焦点可能不在 kitty。
-- 返回光标矩形 {x, y, h}（屏幕坐标），非 kitty 或取不到时返回 nil。
function M.captureAnchor(app)
	if not app or app:bundleID() ~= KITTY_BUNDLE_ID then
		return nil
	end

	local socket = KITTY_SOCKET_PREFIX .. "-" .. app:pid()
	if not hs.fs.attributes(socket) then
		return nil
	end
	-- perl alarm 作超时，避免 kitty 无响应时卡住 Hammerspoon
	local cmd = string.format(
		"/usr/bin/perl -e 'alarm 1; exec @ARGV' %q @ --to %q kitten caret_position.py",
		app:path() .. "/Contents/MacOS/kitten",
		"unix:" .. socket
	)
	local ok, r = pcall(hs.json.decode, hs.execute(cmd) or "")
	if not ok or type(r) ~= "table" or not r.x then
		return nil
	end

	local win = app:focusedWindow()
	if not win then
		return nil
	end
	-- 窗口有标题栏时内容区在窗口底部，用内容区高度推算原点
	local f = win:frame()
	return { x = f.x + r.x, y = f.y + f.h - r.content_h + r.y, h = r.h }
end

function M.hide(fade)
	if hideTimer then
		hideTimer:stop()
		hideTimer = nil
	end
	if canvas then
		canvas:delete(fade or 0)
		canvas = nil
	end
end

function M.show(anchor, text)
	M.hide()

	local textSize = hs.drawing.getTextDrawingSize(text, { size = style.textSize })
	local width = math.ceil(textSize.w + style.horizontalPadding * 2)
	local height = math.ceil(textSize.h + style.verticalPadding * 2)

	local sf = screenFrameAt(anchor)
	-- 默认在光标下方，贴底时放到上方
	local x = anchor.x
	local y = anchor.y + anchor.h + GAP
	if y + height > sf.y + sf.h then
		y = anchor.y - height - GAP
	end
	x = math.max(sf.x, math.min(x, sf.x + sf.w - width))
	y = math.max(sf.y, math.min(y, sf.y + sf.h - height))

	canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:level(hs.canvas.windowLevels.popUpMenu)
	canvas[1] = {
		type = "rectangle",
		action = "fill",
		roundedRectRadii = { xRadius = style.radius, yRadius = style.radius },
		fillColor = style.background,
	}
	canvas[2] = {
		type = "text",
		text = text,
		textColor = style.text,
		textSize = style.textSize,
		textAlignment = "center",
		frame = { x = 0, y = style.verticalPadding, w = width, h = textSize.h },
	}
	canvas:clickActivating(false)
	canvas:show()
	hideTimer = hs.timer.doAfter(DISPLAY_SECONDS, function()
		M.hide(FADE_SECONDS)
	end)
end

return M
