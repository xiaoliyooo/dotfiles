local M = {}
local uiConfig = require("config.ui_config")

local reminderCanvas
local activeTimers = {}

local reminderStyle = {
	background = uiConfig.colors.panelBackground,
	text = uiConfig.colors.primaryText,
	buttonBackground = { alpha = 1, red = 0.82, green = 0.82, blue = 0.83 },
}

local reminders = {
	{
		text = "点外卖",
		times = {
			"11:10",
			"17:20",
		},
	},
	{
		text = "点外卖！",
		times = {
			"11:25",
		},
	},
}

local function closeReminder()
	if reminderCanvas then
		reminderCanvas:delete()
		reminderCanvas = nil
	end
end

local function buildReminderCanvas(text)
	local mainScreen = hs.screen.mainScreen()
	local screenFrame = mainScreen:frame()
	local width = 320
	local height = 180
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
		roundedRectRadii = { xRadius = 18, yRadius = 18 },
		fillColor = reminderStyle.background,
	}
	canvas[2] = {
		type = "text",
		text = text,
		textColor = reminderStyle.text,
		textSize = 34,
		textAlignment = "center",
		frame = { x = 0, y = 40, w = "100%", h = 50 },
	}
	canvas[3] = {
		id = "close_button",
		type = "rectangle",
		action = "fill",
		trackMouseUp = true,
		roundedRectRadii = { xRadius = 10, yRadius = 10 },
		fillColor = reminderStyle.buttonBackground,
		frame = { x = 110, y = 112, w = 100, h = 42 },
	}
	canvas[4] = {
		id = "close_label",
		type = "text",
		text = "关闭",
		trackMouseUp = true,
		textColor = reminderStyle.text,
		textSize = 22,
		textAlignment = "center",
		frame = { x = 110, y = 120, w = 100, h = 24 },
	}
	canvas:mouseCallback(function(_, message, elementId)
		if message == "mouseUp" and (elementId == "close_button" or elementId == "close_label") then
			closeReminder()
		end
	end)

	return canvas
end

function M.showReminder(text)
	closeReminder()
	reminderCanvas = buildReminderCanvas(text)
	reminderCanvas:show()
	reminderCanvas:clickActivating(false)
end

function M.start()
	for _, t in ipairs(activeTimers) do
		t:stop()
	end
	activeTimers = {}

	for _, reminder in ipairs(reminders) do
		for _, time in ipairs(reminder.times) do
			local t = hs.timer.doAt(time, "1d", function()
				M.showReminder(reminder.text)
			end)
			table.insert(activeTimers, t)
		end
	end

	-- 测试代码
	-- hs.hotkey.bind({ "ctrl", "shift" }, "O", function()
	-- 	M.showReminder(reminders[1].text)
	-- end)
	return true
end

return M
