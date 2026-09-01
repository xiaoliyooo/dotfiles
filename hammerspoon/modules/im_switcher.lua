local M = {}

local ABC = "com.apple.keylayout.ABC"
local PINYIN = "com.tencent.inputmethod.wetype.pinyin"
local KOREAN_PREFIX = "com.apple.inputmethod.Korean"
local SWITCH_RETRY_DELAYS = { 0, 0.05, 0.15 }

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

local function switchTo(target, bundleID)
	for _, delay in ipairs(SWITCH_RETRY_DELAYS) do
		hs.timer.doAfter(delay, function()
			if bundleID and not isFrontmost(bundleID) then
				return
			end
			hs.keycodes.currentSourceID(target)
		end)
	end
end

local function switchIfNeeded(app)
	if not app then
		return
	end
	local bundleID = app:bundleID()
	local target = bundleID and appToIM[bundleID]
	if target then
		switchTo(target, bundleID)
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
	switchTo(current == PINYIN and ABC or PINYIN, bundleID)
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
			switchIfNeeded(app)
		end
	end)
	watcher:start()
	switchIfNeeded(hs.application.frontmostApplication())
end

return M
