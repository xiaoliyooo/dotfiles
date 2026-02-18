--- smart-rename: Rename with auto mkdir -p (like nvim-tree)

local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return nil, nil
	end
	return tostring(h.url), tostring(h.name)
end)

local M = {}

function M:entry()
	local old_url, old_name = get_hovered()
	if not old_url or not old_name then
		return
	end

	local parent = old_url:match("(.+)/[^/]+$") or ""

	local new_name, event = ya.input({
		title = "Rename:",
		value = old_name,
		pos = { "hovered", w = 50 },
	})

	if event ~= 1 or not new_name or new_name == "" or new_name == old_name then
		return
	end

	local target = new_name:sub(1, 1) == "/" and new_name or (parent .. "/" .. new_name)

	if new_name:find("/") then
		local target_parent = target:match("(.+)/[^/]+$")
		local s = Command("mkdir"):arg("-p"):arg(target_parent):spawn():wait()
		if not s or not s.success then
			return ya.notify({
				title = "Smart Rename",
				content = "mkdir failed: " .. target_parent,
				level = "error",
				timeout = 5,
			})
		end
	end

	local s = Command("mv"):arg(old_url):arg(target):spawn():wait()
	if not s or not s.success then
		return ya.notify({ title = "Smart Rename", content = "Rename failed", level = "error", timeout = 5 })
	end
end

return M
