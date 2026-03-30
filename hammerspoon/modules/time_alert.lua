local M = {}
local uiConfig = require("config.ui_config")

local timeAlertCanvas
local timeAlertTimer

local WEEKDAYS = {
	[1] = "星期日",
	[2] = "星期一",
	[3] = "星期二",
	[4] = "星期三",
	[5] = "星期四",
	[6] = "星期五",
	[7] = "星期六",
}

local timeAlertStyle = {
	background = uiConfig.colors.panelBackground,
	text = uiConfig.colors.primaryText,
}

local timeAlertLayout = {
	textSize = 32,
	horizontalPadding = 28,
	verticalPadding = 18,
	maxWidthRatio = 0.9,
	minWidth = 320,
	minHeight = 88,
}

local function closeTimeAlert()
	if timeAlertTimer then
		timeAlertTimer:stop()
		timeAlertTimer = nil
	end

	if timeAlertCanvas then
		timeAlertCanvas:delete()
		timeAlertCanvas = nil
	end
end

local function buildTimeAlertCanvas(text)
	local mainScreen = hs.screen.mainScreen()
	local screenFrame = mainScreen:frame()
	local textSize = hs.drawing.getTextDrawingSize(text, {
		size = timeAlertLayout.textSize,
		lineBreak = "clip",
	})
	local width = math.max(
		timeAlertLayout.minWidth,
		math.min(
			screenFrame.w * timeAlertLayout.maxWidthRatio,
			math.ceil(textSize.w + timeAlertLayout.horizontalPadding * 2)
		)
	)
	local height = math.max(timeAlertLayout.minHeight, math.ceil(textSize.h + timeAlertLayout.verticalPadding * 2))
	local frame = {
		x = screenFrame.x + (screenFrame.w - width) / 2,
		y = screenFrame.y + (screenFrame.h - height) / 2,
		w = width,
		h = height,
	}

	local canvas = hs.canvas.new(frame)
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:level(hs.canvas.windowLevels.floating)
	canvas[1] = {
		type = "rectangle",
		action = "fill",
		roundedRectRadii = { xRadius = 16, yRadius = 16 },
		fillColor = timeAlertStyle.background,
	}
	canvas[2] = {
		type = "text",
		text = text,
		textColor = timeAlertStyle.text,
		textSize = timeAlertLayout.textSize,
		textAlignment = "center",
		textLineBreak = "clip",
		frame = {
			x = timeAlertLayout.horizontalPadding,
			y = (height - textSize.h) / 2,
			w = width - timeAlertLayout.horizontalPadding * 2,
			h = textSize.h,
		},
	}

	return canvas
end

local function formatCurrentTime()
	local now = os.date("*t")
	local weekday = WEEKDAYS[now.wday]

	return string.format(
		"📅 %04d年%02d月%02d日  🗓️ %s  🕒 %02d:%02d:%02d",
		now.year,
		now.month,
		now.day,
		weekday,
		now.hour,
		now.min,
		now.sec
	)
end

function M.showCurrentTime()
	local prettyNow = formatCurrentTime()
	closeTimeAlert()
	timeAlertCanvas = buildTimeAlertCanvas(prettyNow)
	timeAlertCanvas:show()
	timeAlertCanvas:clickActivating(false)
	timeAlertTimer = hs.timer.doAfter(2, closeTimeAlert)
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl", "shift" }, "P", M.showCurrentTime)
end

return M
