local M = {}

local ABC = "com.apple.keylayout.ABC"
local SOGOU = "com.sogou.inputmethod.sogou.pinyin"
local KOREAN_PREFIX = "com.apple.inputmethod.Korean"

local abcApps = {
	["com.microsoft.VSCode"] = "Visual Studio Code",
	["com.google.antigravity"] = "Antigravity",
	["com.googlecode.iterm2"] = "iTerm",
	["net.kovidgoyal.kitty"] = "kitty",
	["com.apple.finder"] = "访达",
	["com.jinghaoshe.qspace.pro"] = "QSpace Pro",
}

local sogouApps = {
	["com.tencent.xinWeChat"] = "微信",
	["com.electron.lark"] = "飞书",
}

local appToIM = {}
for bundleID in pairs(abcApps) do
	appToIM[bundleID] = ABC
end
for bundleID in pairs(sogouApps) do
	appToIM[bundleID] = SOGOU
end

local function switchIfNeeded(app)
	if not app then
		return
	end
	local bundleID = app:bundleID()
	if not bundleID then
		return
	end

	local target = appToIM[bundleID]
	if not target then
		return
	end

	if hs.keycodes.currentSourceID() == target then
		return
	end

	hs.keycodes.currentSourceID(target)
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
	hs.keycodes.currentSourceID(current == SOGOU and ABC or SOGOU)
end

function M.toKorean()
	local korean = cycleSources()
	if korean then
		hs.keycodes.currentSourceID(korean)
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
