local M = {}
local log = hs.logger.new("im_switcher")

local ABC = "com.apple.keylayout.ABC"
local PINYIN = "com.tencent.inputmethod.wetype.pinyin"
local KOREAN_PREFIX = "com.apple.inputmethod.Korean"
local MACISM_TEMPORARY_WINDOW_BUNDLE_ID = "laishulu.macism.TemporaryWindow"
local FINDER_BUNDLE_ID = "com.apple.finder"

local macismOutput, macismFound = hs.execute("command -v macism", true)
local macismPath = macismOutput:match("([^\r\n]+)%s*$")
assert(macismFound and macismPath, "macism not found in PATH")

local appToIM = {
	-- ABC
	["com.microsoft.VSCode"] = ABC, -- Visual Studio Code
	["com.google.antigravity"] = ABC, -- Antigravity
	["com.googlecode.iterm2"] = ABC, -- iTerm
	["net.kovidgoyal.kitty"] = ABC, -- kitty
	["com.apple.finder"] = ABC, -- 访达
	["com.jinghaoshe.qspace.pro"] = ABC, -- QSpace Pro
	-- 微信输入法
	["com.tencent.xinWeChat"] = PINYIN, -- 微信
	["com.electron.lark"] = PINYIN, -- 飞书
	["com.bot.pc.doubao"] = PINYIN, -- 豆包
}

local function isFrontmost(bundleID)
	local app = hs.application.frontmostApplication()
	return app and app:bundleID() == bundleID
end

local activeTask
local switchRequest = 0
local ignoredActivationBundleID
local ignoredActivationTimer

local function invalidateSwitch()
	switchRequest = switchRequest + 1
end

local function clearIgnoredActivation()
	ignoredActivationBundleID = nil
	if ignoredActivationTimer then
		ignoredActivationTimer:stop()
		ignoredActivationTimer = nil
	end
end

local function ignoreNextActivation(bundleID)
	clearIgnoredActivation()
	ignoredActivationBundleID = bundleID
	ignoredActivationTimer = hs.timer.doAfter(1, clearIgnoredActivation)
end

local function cancelSwitch()
	invalidateSwitch()
	clearIgnoredActivation()

	if activeTask then
		activeTask:terminate()
		activeTask = nil
	end
end

local function runMacism(target, bundleID, request)
	if request ~= switchRequest or (bundleID and not isFrontmost(bundleID)) then
		return
	end

	local task
	local arguments = { target }
	if bundleID == FINDER_BUNDLE_ID then
		-- Finder's rename field loses focus when TemporaryWindow is activated.
		arguments[#arguments + 1] = "0"
	end
	task = hs.task.new(macismPath, function(exitCode, _, stderr)
		if activeTask == task then
			activeTask = nil
		end

		if request ~= switchRequest then
			return
		end

		if exitCode ~= 0 then
			local detail = stderr and stderr:gsub("%s+$", "") or "unknown error"
			log.e("macism failed (%s): %s", tostring(exitCode), detail)
		end
	end, arguments)

	if not task then
		log.e("failed to create macism task")
		return
	end

	if target ~= ABC and bundleID then
		ignoreNextActivation(bundleID)
	end

	activeTask = task
	if not task:start() then
		clearIgnoredActivation()
		if request == switchRequest then
			activeTask = nil
		end
		log.e("failed to start macism")
	end
end

local function switchTo(target, bundleID)
	if not target then
		return
	end

	cancelSwitch()
	local request = switchRequest
	runMacism(target, bundleID, request)
end

local function switchIfNeeded(app)
	if not app then
		return
	end
	local bundleID = app:bundleID()
	local target = bundleID and appToIM[bundleID]
	if target then
		switchTo(target, bundleID)
	else
		-- Do not kill macism while its temporary window is refreshing the input context.
		invalidateSwitch()
	end
end

local watcher

local function cycleSources()
	local sources = hs.fnutils.concat(hs.keycodes.layouts(true), hs.keycodes.methods(true))
	for _, id in ipairs(sources) do
		if id:sub(1, #KOREAN_PREFIX) == KOREAN_PREFIX then
			return id
		end
	end
end

function M.toggle()
	local current = hs.keycodes.currentSourceID()
	local app = hs.application.frontmostApplication()
	local bundleID = app and app:bundleID()
	local target = current == PINYIN and ABC or PINYIN
	switchTo(target, bundleID)
end

function M.toKorean()
	local korean = cycleSources()
	if korean then
		local app = hs.application.frontmostApplication()
		local bundleID = app and app:bundleID()
		switchTo(korean, bundleID)
	end
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl" }, "Q", M.toggle)
	hs.hotkey.bind({ "ctrl", "shift" }, "Q", M.toKorean)
end

function M.start()
	watcher = hs.application.watcher.new(function(_, eventType, app)
		if eventType == hs.application.watcher.activated then
			local bundleID = app and app:bundleID()
			if bundleID == MACISM_TEMPORARY_WINDOW_BUNDLE_ID then
				return
			end
			if bundleID and bundleID == ignoredActivationBundleID then
				clearIgnoredActivation()
				return
			end
			switchIfNeeded(app)
		end
	end)
	watcher:start()
	switchIfNeeded(hs.application.frontmostApplication())
end

return M
