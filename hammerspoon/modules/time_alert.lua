local M = {}
local palette = require("config.ui_config").lightCard

local DISPLAY_SECONDS = 3.0
local FADE_IN_SECONDS = 0.15
local FADE_OUT_SECONDS = 0.18
local DECIMAL_GB = 1000 ^ 3

local WEEKDAYS = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }

local layout = {
	shadowMargin = 40,
	cardRadius = 28,
	minCardWidth = 468,
	horizontalPadding = 46,
	topPadding = 30,
	bottomPadding = 24,
	dateGapTop = 10,
	sectionGapTop = 22,
	sectionInsetX = 24,
	sectionRadius = 18,
	sectionPadX = 22,
	sectionPadTop = 17,
	sectionPadBottom = 19,
	metricRowGap = 16,
	metricBarGap = 8,
	barHeight = 9,
	timeFontSize = 62,
	dateFontSize = 19,
	badgeFontSize = 16.5,
	badgeGap = 12,
	badgePadX = 14,
	badgeMinHeight = 31,
	metricLabelSize = 16.5,
	metricValueSize = 16.5,
}

local function pickFont(candidates)
	for _, name in ipairs(candidates) do
		if hs.styledtext.validFont(name) then
			return name
		end
	end
	return ".AppleSystemUIFont"
end

local MONO_FONT = pickFont({ "JetBrainsMonoNL-Bold", "JetBrainsMono-Regular", "SFMono-Bold", "Menlo-Bold" })
local DATE_FONT = pickFont({ "PingFangSC-Medium", "PingFangSC-Regular" })
local SEMIBOLD_FONT = pickFont({ "PingFangSC-Semibold", "PingFangSC-Medium" })

local canvas
local state
local timers = {}
local prevCpuTicks = hs.host.cpuUsageTicks()
local prevCpuSampleAt = hs.timer.secondsSinceEpoch()
local lastCpuPercent = 0

local function stopTimers()
	for k, t in pairs(timers) do
		t:stop()
		timers[k] = nil
	end
end

local function closeTimeAlert(fadeSeconds)
	stopTimers()
	state = nil
	if canvas then
		local c = canvas
		canvas = nil
		c:mouseCallback(nil)
		c:delete(fadeSeconds or 0)
	end
end

local function clampPercent(pct)
	if type(pct) ~= "number" or pct ~= pct then
		return 0
	end
	return math.max(0, math.min(100, pct))
end

local function computeCpuDelta(prev, curr)
	local p, c = prev and prev.overall, curr and curr.overall
	if not p or not c then
		return lastCpuPercent
	end
	local dActive = (c.active or 0) - (p.active or 0)
	local dTotal = dActive + (c.idle or 0) - (p.idle or 0)
	return dTotal > 0 and clampPercent(dActive / dTotal * 100) or lastCpuPercent
end

-- 非阻塞采样：距上次采样过久时先重置基线，并在淡入结束时补采一次瞬时负载
local function sampleCpuPercent(forceDelta)
	local nowSec = hs.timer.secondsSinceEpoch()
	local currTicks = hs.host.cpuUsageTicks()
	local elapsed = nowSec - prevCpuSampleAt
	local fresh = forceDelta or (elapsed >= 0.08 and elapsed <= 5.0)

	if fresh or lastCpuPercent == 0 then
		lastCpuPercent = computeCpuDelta(prevCpuTicks, currTicks)
	end
	prevCpuTicks, prevCpuSampleAt = currTicks, nowSec
	return lastCpuPercent, not fresh
end

local function queryDiskStats()
	local ok, vols = pcall(hs.host.volumeInformation)
	local root = ok and type(vols) == "table" and (vols["/System/Volumes/Data"] or vols["/"])
	local totalBytes = root and root.NSURLVolumeTotalCapacityKey or 0
	if totalBytes <= 0 then
		return { percent = 0, detailText = "--" }
	end

	local usedBytes = math.max(0, totalBytes - (root.NSURLVolumeAvailableCapacityKey or 0))
	local totalGB, usedGB = totalBytes / DECIMAL_GB, usedBytes / DECIMAL_GB
	local detail = totalGB >= 1000 and string.format("%.2f / %.2f TB", usedGB / 1000, totalGB / 1000)
		or string.format("%.0f / %.0f GB", usedGB, totalGB)
	return { percent = clampPercent(usedBytes / totalBytes * 100), detailText = detail }
end

local function levelColor(pct, warnAt, dangerAt, normalColor)
	if pct >= dangerAt then
		return palette.barDanger
	elseif pct >= warnAt then
		return palette.barWarn
	end
	return normalColor
end

local function styled(raw, font, size, color, align, kerning)
	return hs.styledtext.new(raw, {
		font = { name = font, size = size },
		color = color,
		kerning = kerning or 0,
		ligature = 0,
		paragraphStyle = { alignment = align, lineBreak = "clip" },
	})
end

local function buildTimeText(now)
	return styled(
			string.format("%02d:%02d:%02d", now.hour, now.min, now.sec),
			MONO_FONT,
			layout.timeFontSize,
			palette.timePrimary,
			"center",
			1.0
		)
		:setStyle({ color = palette.timeSeparator }, 3, 3)
		:setStyle({ color = palette.timeSeparator }, 6, 6)
		:setStyle({ color = palette.accent }, 7, 8)
end

local function buildDateText(now)
	return styled(
		string.format("%04d年%02d月%02d日", now.year, now.month, now.day),
		DATE_FONT,
		layout.dateFontSize,
		palette.secondaryText,
		"left",
		0.3
	)
end

local function buildWeekdayText(now)
	return styled(WEEKDAYS[now.wday] or "", SEMIBOLD_FONT, layout.badgeFontSize, palette.badgeText, "center", 0.5)
end

local function buildCpuValueText(pct)
	return styled(
		string.format("%.1f%%", pct),
		MONO_FONT,
		layout.metricValueSize,
		levelColor(pct, 65, 85, palette.timePrimary),
		"right"
	)
end

local function buildDiskValueText(disk)
	local color = levelColor(disk.percent, 75, 90, palette.timePrimary)
	local detail = styled(disk.detailText .. "  ", MONO_FONT, layout.metricValueSize - 1, palette.mutedText, "right")
	local pct = styled(string.format("%.0f%%", disk.percent), MONO_FONT, layout.metricValueSize, color, "right")
	return detail .. pct
end

local function barFill(barX, barY, barW, pct, color)
	local h = layout.barHeight
	if pct <= 0.2 then
		return "skip", color, { x = barX, y = barY, w = 0, h = h }
	end
	local w = math.max(h, math.min(barW, math.floor(barW * pct / 100 + 0.5)))
	return "fill", color, { x = barX, y = barY, w = w, h = h }
end

local function appendMetricRow(c, grid, rowTopY, labelText, labelH, valueText, valueH, pct, color)
	local textCenterY = rowTopY + grid.textH / 2
	local barY = rowTopY + grid.textH + layout.metricBarGap
	local barRadius = layout.barHeight / 2
	local action, fillColor, fillFrame = barFill(grid.barX, barY, grid.barW, pct, color)
	local base = c:elementCount()
	c:appendElements({
		type = "text",
		text = labelText,
		frame = { x = grid.barX, y = textCenterY - labelH / 2, w = grid.labelW, h = labelH },
	}, {
		type = "text",
		text = valueText,
		frame = { x = grid.barX + grid.labelW, y = textCenterY - valueH / 2, w = grid.barW - grid.labelW, h = valueH },
	}, {
		type = "rectangle",
		action = "fill",
		roundedRectRadii = { xRadius = barRadius, yRadius = barRadius },
		fillColor = palette.barTrack,
		frame = { x = grid.barX, y = barY, w = grid.barW, h = layout.barHeight },
	}, {
		type = "rectangle",
		action = action,
		roundedRectRadii = { xRadius = barRadius, yRadius = barRadius },
		fillColor = fillColor,
		frame = fillFrame,
	})
	return { valueIdx = base + 2, fillIdx = base + 4, barY = barY }
end

local function buildCanvas(screen, now, cpuPct, disk)
	local c = hs.canvas.new({ x = 0, y = 0, w = 100, h = 100 })
	c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	c:level(hs.canvas.windowLevels.floating)

	local timeText = buildTimeText(now)
	local dateText = buildDateText(now)
	local weekdayText = buildWeekdayText(now)
	local cpuLabel = styled("CPU", MONO_FONT, layout.metricLabelSize, palette.metricLabel, "left", 0.3)
	local diskLabel = styled("硬盘", SEMIBOLD_FONT, layout.metricLabelSize, palette.metricLabel, "left", 0.3)
	local cpuValue = buildCpuValueText(cpuPct)
	local diskValue = buildDiskValueText(disk)

	local timeSize = c:minimumTextSize(timeText)
	local dateSize = c:minimumTextSize(dateText)
	local weekdaySize = c:minimumTextSize(weekdayText)
	local cpuLabelSize = c:minimumTextSize(cpuLabel)
	local diskLabelSize = c:minimumTextSize(diskLabel)
	local cpuValueH = math.ceil(c:minimumTextSize(cpuValue).h)
	local diskValueH = math.ceil(c:minimumTextSize(diskValue).h)

	local timeW, timeH = math.ceil(timeSize.w) + 8, math.ceil(timeSize.h)
	local dateW, dateH = math.ceil(dateSize.w) + 2, math.ceil(dateSize.h)
	local weekdayH = math.ceil(weekdaySize.h)
	local badgeW = math.ceil(weekdaySize.w) + layout.badgePadX * 2
	local badgeH = math.max(layout.badgeMinHeight, weekdayH + 8)
	local dateGroupW = dateW + layout.badgeGap + badgeW
	local dateRowH = math.max(dateH, badgeH)

	local cpuLabelH, diskLabelH = math.ceil(cpuLabelSize.h), math.ceil(diskLabelSize.h)
	local metricTextH = math.max(22, cpuLabelH, diskLabelH, cpuValueH, diskValueH)
	local labelColW = math.max(math.ceil(cpuLabelSize.w), math.ceil(diskLabelSize.w)) + 14

	local sectionH = layout.sectionPadTop
		+ metricTextH * 2
		+ layout.metricBarGap * 2
		+ layout.barHeight * 2
		+ layout.metricRowGap
		+ layout.sectionPadBottom

	local cardW = math.max(layout.minCardWidth, math.max(timeW, dateGroupW) + layout.horizontalPadding * 2)
	local cardH = layout.topPadding
		+ timeH
		+ layout.dateGapTop
		+ dateRowH
		+ layout.sectionGapTop
		+ sectionH
		+ layout.bottomPadding

	local margin = layout.shadowMargin
	local canvasW, canvasH = cardW + margin * 2, cardH + margin * 2
	local sf = screen:frame()
	c:frame({
		x = math.floor(sf.x + (sf.w - canvasW) / 2),
		y = math.floor(sf.y + (sf.h - canvasH) * 0.46),
		w = canvasW,
		h = canvasH,
	})

	local cardX, cardY = margin, margin
	local timeY = cardY + layout.topPadding
	local dateCenterY = timeY + timeH + layout.dateGapTop + dateRowH / 2
	local dateStartX = cardX + math.floor((cardW - dateGroupW) / 2)
	local badgeX = dateStartX + dateW + layout.badgeGap
	local badgeRadius = badgeH / 2

	local sectionX = cardX + layout.sectionInsetX
	local sectionY = timeY + timeH + layout.dateGapTop + dateRowH + layout.sectionGapTop
	local sectionW = cardW - layout.sectionInsetX * 2
	local barX, barW = sectionX + layout.sectionPadX, sectionW - layout.sectionPadX * 2

	c:appendElements({
		id = "card_bg",
		type = "rectangle",
		action = "strokeAndFill",
		trackMouseUp = true,
		roundedRectRadii = { xRadius = layout.cardRadius, yRadius = layout.cardRadius },
		fillGradient = "linear",
		fillGradientAngle = 90,
		fillGradientColors = { palette.surfaceTop, palette.surfaceBottom },
		strokeColor = palette.outerBorder,
		strokeWidth = 1,
		withShadow = true,
		shadow = { blurRadius = 26, color = palette.shadow, offset = { w = 0, h = -10 } },
		frame = { x = cardX, y = cardY, w = cardW, h = cardH },
	}, {
		type = "rectangle",
		action = "stroke",
		roundedRectRadii = { xRadius = layout.cardRadius - 1, yRadius = layout.cardRadius - 1 },
		strokeColor = palette.innerHighlight,
		strokeWidth = 1,
		frame = { x = cardX + 1, y = cardY + 1, w = cardW - 2, h = cardH - 2 },
	}, {
		type = "text",
		text = timeText,
		frame = { x = cardX, y = timeY, w = cardW, h = timeH },
	}, {
		type = "text",
		text = dateText,
		frame = { x = dateStartX, y = dateCenterY - dateH / 2, w = dateW, h = dateH },
	}, {
		type = "rectangle",
		action = "strokeAndFill",
		roundedRectRadii = { xRadius = badgeRadius, yRadius = badgeRadius },
		fillColor = palette.badgeBackground,
		strokeColor = palette.badgeBorder,
		strokeWidth = 1,
		frame = { x = badgeX, y = dateCenterY - badgeH / 2, w = badgeW, h = badgeH },
	}, {
		type = "text",
		text = weekdayText,
		frame = { x = badgeX, y = dateCenterY - weekdayH / 2, w = badgeW, h = weekdayH },
	}, {
		type = "rectangle",
		action = "strokeAndFill",
		roundedRectRadii = { xRadius = layout.sectionRadius, yRadius = layout.sectionRadius },
		fillColor = palette.sectionBackground,
		strokeColor = palette.sectionBorder,
		strokeWidth = 1,
		frame = { x = sectionX, y = sectionY, w = sectionW, h = sectionH },
	})

	local grid = { barX = barX, barW = barW, labelW = labelColW, textH = metricTextH }
	local cpuTopY = sectionY + layout.sectionPadTop
	local cpuRow = appendMetricRow(
		c,
		grid,
		cpuTopY,
		cpuLabel,
		cpuLabelH,
		cpuValue,
		cpuValueH,
		cpuPct,
		levelColor(cpuPct, 65, 85, palette.accent)
	)
	local diskTopY = cpuRow.barY + layout.barHeight + layout.metricRowGap
	local diskRow = appendMetricRow(
		c,
		grid,
		diskTopY,
		diskLabel,
		diskLabelH,
		diskValue,
		diskValueH,
		disk.percent,
		levelColor(disk.percent, 75, 90, palette.barDiskGood)
	)

	c:mouseCallback(function(_, message, elementId)
		if message == "mouseUp" and elementId == "card_bg" then
			closeTimeAlert(FADE_OUT_SECONDS)
		end
	end)
	c:clickActivating(false)

	state = {
		screenId = screen:id(),
		day = now.day,
		barX = barX,
		barW = barW,
		timeIdx = 3,
		dateIdx = 4,
		weekdayIdx = 6,
		cpu = cpuRow,
		disk = diskRow,
	}
	return c
end

local function updateMetric(row, valueText, pct, color)
	local action, fillColor, frame = barFill(state.barX, row.barY, state.barW, pct, color)
	canvas[row.valueIdx].text = valueText
	canvas[row.fillIdx].action = action
	canvas[row.fillIdx].fillColor = fillColor
	canvas[row.fillIdx].frame = frame
end

local function refreshMetrics(cpuPct)
	if not canvas or not state then
		return
	end
	local disk = queryDiskStats()
	updateMetric(state.cpu, buildCpuValueText(cpuPct), cpuPct, levelColor(cpuPct, 65, 85, palette.accent))
	updateMetric(
		state.disk,
		buildDiskValueText(disk),
		disk.percent,
		levelColor(disk.percent, 75, 90, palette.barDiskGood)
	)
end

local function scheduleNextTick()
	if not canvas then
		return
	end
	local delay = 1 - (hs.timer.secondsSinceEpoch() % 1) + 0.01
	timers.tick = hs.timer.doAfter(delay, function()
		if not canvas or not state then
			return
		end
		local now = os.date("*t")
		canvas[state.timeIdx].text = buildTimeText(now)
		if now.day ~= state.day then
			state.day = now.day
			canvas[state.dateIdx].text = buildDateText(now)
			canvas[state.weekdayIdx].text = buildWeekdayText(now)
		end
		refreshMetrics(sampleCpuPercent(true))
		scheduleNextTick()
	end)
end

function M.showCurrentTime()
	local mainScreen = hs.screen.mainScreen()
	local now = os.date("*t")
	local cpuPct, needsBootstrap = sampleCpuPercent(false)

	if canvas and state and state.screenId == mainScreen:id() then
		stopTimers()
		canvas[state.timeIdx].text = buildTimeText(now)
		refreshMetrics(cpuPct)
	else
		closeTimeAlert(0)
		canvas = buildCanvas(mainScreen, now, cpuPct, queryDiskStats())
		canvas:show(FADE_IN_SECONDS)
	end

	if needsBootstrap then
		timers.bootstrap = hs.timer.doAfter(0.16, function()
			timers.bootstrap = nil
			if canvas and state then
				local pct = sampleCpuPercent(true)
				updateMetric(state.cpu, buildCpuValueText(pct), pct, levelColor(pct, 65, 85, palette.accent))
			end
		end)
	end
	scheduleNextTick()
	timers.hide = hs.timer.doAfter(DISPLAY_SECONDS, function()
		closeTimeAlert(FADE_OUT_SECONDS)
	end)
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl", "shift" }, "P", M.showCurrentTime)
end

return M
