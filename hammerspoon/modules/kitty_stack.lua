local M = {}

--- 将所有 Kitty 窗口按高度从大到小排序层级（矮的在前，高的在后）
function M.stackByHeight()
	local kittyApp = hs.application.get("kitty")
	if not kittyApp then
		hs.alert.show("Kitty is not running")
		return
	end

	local windows = kittyApp:allWindows()
	if #windows <= 1 then
		hs.alert.show("Only " .. #windows .. " Kitty window(s)")
		return
	end

	-- 按窗口高度降序排列：最高的先 raise（垫底），最矮的最后 raise（最前）
	table.sort(windows, function(a, b)
		return a:frame().h > b:frame().h
	end)

	for _, win in ipairs(windows) do
		win:raise()
	end

	hs.alert.show("Stacked " .. #windows .. " Kitty windows")
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl", "shift" }, "t", M.stackByHeight)
end

return M
