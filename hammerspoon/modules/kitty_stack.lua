local M = {}

-- 每个非激活窗口之间的高度递增步长（露出 tab 高度）
local HEIGHT_STEP = 30

--- 重新排列所有 Kitty 窗口：
--- 1. 当前激活窗口保持不动
--- 2. 其余窗口高度从屏幕一半开始，依次增大 HEIGHT_STEP
--- 3. 顶部靠顶对齐，矮的在上（z-order 最前），高的在下（z-order 最后）
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

	local focusedWin = hs.window.focusedWindow()
	local screen = (focusedWin and focusedWin:screen()) or hs.screen.mainScreen()
	local screenFrame = screen:frame()

	-- 分离出非激活的 Kitty 窗口
	local others = {}
	for _, win in ipairs(windows) do
		if not focusedWin or win:id() ~= focusedWin:id() then
			table.insert(others, win)
		end
	end

	-- 基础高度 = 屏幕高度的 60%
	local baseHeight = screenFrame.h * 0.6

	-- 对非激活窗口按索引分配递增高度，并设置 frame
	-- 排列后：index 1 最矮 → index n 最高
	for i, win in ipairs(others) do
		local h = baseHeight + (i - 1) * HEIGHT_STEP
		-- 限制不超过屏幕高度
		if h > screenFrame.h then
			h = screenFrame.h
		end

		local f = win:frame()
		f.x = screenFrame.x
		f.y = screenFrame.y -- 顶部靠顶
		f.w = screenFrame.w
		f.h = h
		win:setFrame(f)
	end

	-- z-order 排列：最高的先 raise（垫底），最矮的最后 raise（最前）
	-- 再把激活窗口放最顶层
	for i = #others, 1, -1 do
		others[i]:raise()
	end
	if focusedWin then
		focusedWin:raise()
		focusedWin:focus()
	end

	hs.alert.show("Stacked " .. #windows .. " Kitty windows")
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl", "shift" }, "t", M.stackByHeight)
end

return M
