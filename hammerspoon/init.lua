-- reload start
function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config reloaded")
-- reload end

local timeAlert = require("modules.time_alert")
timeAlert.bindHotkeys()

local reminder = require("modules.reminder")
reminder.start()

local imSwitcher = require("modules.im_switcher")
imSwitcher.start()
