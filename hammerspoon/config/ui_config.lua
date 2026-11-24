local M = {}

M.colors = {
	panelBackground = { alpha = 0.96, red = 0.94, green = 0.94, blue = 0.95 },
	primaryText = { alpha = 1, red = 0.08, green = 0.08, blue = 0.08 },
}

M.lightCard = {
	surfaceTop = { red = 1.00, green = 1.00, blue = 1.00, alpha = 0.98 },
	surfaceBottom = { red = 0.965, green = 0.973, blue = 0.988, alpha = 0.98 },
	outerBorder = { red = 0.06, green = 0.09, blue = 0.16, alpha = 0.09 },
	innerHighlight = { red = 1.00, green = 1.00, blue = 1.00, alpha = 0.85 },
	shadow = { red = 0.06, green = 0.09, blue = 0.18, alpha = 0.16 },
	timePrimary = { red = 0.07, green = 0.09, blue = 0.15, alpha = 1.00 },
	timeSeparator = { red = 0.60, green = 0.66, blue = 0.74, alpha = 1.00 },
	accent = { red = 0.15, green = 0.43, blue = 0.91, alpha = 1.00 },
	secondaryText = { red = 0.35, green = 0.40, blue = 0.49, alpha = 1.00 },
	mutedText = { red = 0.46, green = 0.52, blue = 0.61, alpha = 1.00 },
	badgeBackground = { red = 0.15, green = 0.43, blue = 0.91, alpha = 0.10 },
	badgeBorder = { red = 0.15, green = 0.43, blue = 0.91, alpha = 0.20 },
	badgeText = { red = 0.13, green = 0.38, blue = 0.84, alpha = 1.00 },
	sectionBackground = { red = 0.945, green = 0.958, blue = 0.982, alpha = 0.92 },
	sectionBorder = { red = 0.06, green = 0.09, blue = 0.16, alpha = 0.05 },
	metricLabel = { red = 0.22, green = 0.27, blue = 0.35, alpha = 1.00 },
	barTrack = { red = 0.07, green = 0.11, blue = 0.20, alpha = 0.08 },
	barDiskGood = { red = 0.09, green = 0.60, blue = 0.50, alpha = 1.00 },
	barWarn = { red = 0.91, green = 0.56, blue = 0.08, alpha = 1.00 },
	barDanger = { red = 0.87, green = 0.25, blue = 0.25, alpha = 1.00 },
}

return M
