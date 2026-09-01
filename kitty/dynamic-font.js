#!/usr/bin/osascript -l JavaScript
// Generate a Kitty font size from the main display's pixel width.

ObjC.import('CoreGraphics');
ObjC.import('Foundation');

const SMALL_DISPLAY_FONT_SIZE = 13;
const MEDIUM_DISPLAY_FONT_SIZE = 14;
const LARGE_DISPLAY_FONT_SIZE = 15;

function mainDisplayWidth() {
  const displayID = $.CGMainDisplayID();
  return Number($.CGDisplayPixelsWide(displayID));
}

function fontSizeFor(width) {
  if (width >= 5120) return LARGE_DISPLAY_FONT_SIZE;

  if (width >= 3840) return MEDIUM_DISPLAY_FONT_SIZE;

  return SMALL_DISPLAY_FONT_SIZE;
}

try {
  const fontSize = fontSizeFor(mainDisplayWidth());

  // Kitty parses stdout as configuration. JXA's console.log writes to stderr.
  const output = `font_size ${fontSize}\n`;
  const data = $(output).dataUsingEncoding($.NSUTF8StringEncoding);
  $.NSFileHandle.fileHandleWithStandardOutput.writeData(data);
} catch (_) {
  // Keep kitty.conf's static font_size when display information is unavailable.
}
