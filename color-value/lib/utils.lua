---@diagnostic disable-next-line: undefined-global
local defaultSourcePrecision = L.defaultSourcePrecision
---@diagnostic disable-next-line: undefined-global
local isUTF8Compatible = L.isUTF8Compatible
---@diagnostic disable-next-line: undefined-global
local __ = L.translate
---@diagnostic disable-next-line: undefined-global
local needsDialogReflow = L.needsDialogReflow

local ANSI_BLACK = "\27[1;30m"
local ANSI_RED = "\27[1;31m"
local ANSI_GREEN = "\27[1;32m"
local ANSI_YELLOW = "\27[1;33m"
local ANSI_CYAN = "\27[0;36m"
local function log(text, ansiColor)
    if not ansiColor then ansiColor = ANSI_CYAN end -- black is unreadable on ethos.studio1247.com
    local ANSI_RESET = "\27[0m"
    print(ansiColor .. "[cv]" .. tostring(text) .. ANSI_RESET)
end

local function isSensor(source)
    return source and source:category() == CATEGORY_TELEMETRY_SENSOR
end
local function isTimer(source)
    return source and source:category() == CATEGORY_TIMER
end
local function sourceExists(source)
    return source and source:category() ~= CATEGORY_NONE
end

local function replaceUTF8(text, altChar)
    if not altChar then altChar = " " end
    return tostring(text):gsub("[\128-\255\194-\244][\128-\191]*", altChar)
end

-- set the font to fit text into a box (fit maxWidth and fit maxHeight) maxWidth or maxHeight may be nil
local function bestFit(strOrTable, fontIndexList, maxWidth, maxHeight, altChar, startIndex, endIndex)
    local boxW, boxH, bestFontIndex, lineH
    local overflow = true
    local lineCount = 1
    local sType = 0 -- string
    startIndex = startIndex or 1
    endIndex = endIndex or #fontIndexList
    if type(strOrTable) == "table" then
        sType = 1
        lineCount = #strOrTable
    end

    for index = startIndex, endIndex do
        local font = fontIndexList[index]
        local line
        boxW = 0
        boxH = 0
        lineH = 0
        overflow = true
        lcd.font(font)
        bestFontIndex = index
        for i = 1, lineCount do
            if i == 1 and sType == 0 then
                line = strOrTable
            else
                line = strOrTable[i]
            end
            if not isUTF8Compatible then
                line = replaceUTF8(line, altChar)
            end
            local w, h = lcd.getTextSize(line)
            boxW = math.max(boxW, w)
            boxH = boxH + h
            lineH = math.max(lineH, h)
        end
        if (maxWidth == nil or (maxWidth and boxW <= maxWidth)) and (maxHeight == nil or (maxHeight and boxH <= maxHeight)) then
            overflow = false
            break
        end
    end
    return boxW, boxH, lineH, bestFontIndex, overflow
end

-- set the font for the best overlap (fit maxWidth OR fit maxHeight)
local function bestOverlap(str, fontList, maxWidth, maxHeight, altChar, startIndex, endIndex)
    local text = str
    if not isUTF8Compatible then
        text = replaceUTF8(str, altChar)
    end
    local tw, th, bestFontIndex
    local overflow = true
    startIndex = startIndex or 1
    endIndex = endIndex or #fontList
    for i = startIndex, endIndex do
        local font = fontList[i]
        lcd.font(font)
        bestFontIndex = i
        tw, th = lcd.getTextSize(text)
        if th < maxHeight or tw < maxWidth then
            overflow = false
            break
        end
    end
    return tw, th, bestFontIndex, overflow
end

local function formatWithDecimals(value, source)
    return string.format("%.0" .. (source:decimals() or defaultSourcePrecision) .. "f", value or 0)
end
local function trim(s)
    if not s then return "" end
    return tostring(s):gsub("^%s*(.-)%s*$", "%1")
end
--- wraps in a confirm dialog, accept fn of a text button or options of a button
---@param fn (function)
---@return any
local function confirm(fn, message, width)
    return function()
        return form.openDialog({
            title = string.format(__("confirmTitle")),
            message = message,
            width = width,
            buttons = {
                { label = __("no"),  action = function() return true end },
                { label = __("yes"), action = function() return fn() or true end },
            },
            options = TEXT_LEFT
        })
    end
end
--[[
--I used this to find the theme color of titleColor (14)
function lcd.unRGB(rgba)
  -- BEWARE, this might be hardware specific
  return
    ((rgba & 0x0000f800) >> 11) * 8,
    ((rgba & 0x000007e0) >> 5) * 4,
    ((rgba & 0x0000001f) >> 0) * 8,
    ((rgba & 0x0f000000) >> 24) * 16
end
for i=0,17, 1 do
    local r,g,b,a = lcd.unRGB(lcd.themeColor(i))
    print(string.format("Theme %s #%02x%02x%02x%02x", i, r, g, b, a))
end
 ]]

local function wrap(str, limit, indent, indent1)
    indent = indent or ""
    indent1 = indent1 or indent
    limit = limit or 72
    local here = 1 - #indent1
    local function check(sp, st, word, fi)
        if fi - here > limit then
            here = st - #indent
            return "\n" .. indent .. word
        end
    end
    return indent1 .. str:gsub("(%s+)()(%S+)()", check)
end
local function reflow(str, limit, indent, indent1)
    if not needsDialogReflow then return str end
    return (str:gsub("[^\n]+",
        function(line)
            return wrap(line, limit, indent, indent1)
        end))
end

return {
    isSensor = isSensor,
    isTimer = isTimer,
    sourceExists = sourceExists,
    replaceUTF8 = replaceUTF8,
    bestFit = bestFit,
    bestOverlap = bestOverlap,
    formatWithDecimals = formatWithDecimals,
    confirm = confirm,
    trim = trim,
    log = log,
    ANSI_RED = ANSI_RED,
    ANSI_GREEN = ANSI_GREEN,
    ANSI_YELLOW = ANSI_YELLOW,
    reflow = reflow,
}
