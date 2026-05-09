local M = {}

local ABC = "com.apple.keylayout.ABC"
local SOGOU = "com.sogou.inputmethod.sogou.pinyin"

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
