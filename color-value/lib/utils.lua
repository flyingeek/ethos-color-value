---@diagnostic disable-next-line: undefined-global
local defaultSourcePrecision = L.defaultSourcePrecision
---@diagnostic disable-next-line: undefined-global
local isUTF8Compatible = L.isUTF8Compatible
---@diagnostic disable-next-line: undefined-global
local __ = L.translate

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
local function bestFit(str, fontIndexList, maxWidth, maxHeight, altChar)
    local text = str
    if not isUTF8Compatible then
        text = replaceUTF8(str, altChar)
    end
    local tw, th
    local overflow = true
    for _, font in pairs(fontIndexList) do
        lcd.font(font)
        tw, th = lcd.getTextSize(text)
        if (maxWidth == nil or (maxWidth and tw <= maxWidth)) and (maxHeight == nil or (maxHeight and th <= maxHeight)) then
            overflow = false
            break
        end
    end
    return tw, th, overflow
end

-- set the font for the best overlap (fit maxWidth OR fit maxHeight)
local function bestOverlap(str, fontList, maxWidth, maxHeight, altChar)
    local text = str
    if not isUTF8Compatible then
        text = replaceUTF8(str, altChar)
    end
    local tw, th
    local overflow = true
    for _, font in pairs(fontList) do
        lcd.font(font)
        tw, th = lcd.getTextSize(text)
        if th < maxHeight or tw < maxWidth then
            overflow = false
            break
        end
    end
    return tw, th, overflow
end

local function formatWithDecimals(value, source)
    if not value then return "" end
    return string.format("%.0" .. (source:decimals() or defaultSourcePrecision) .. "f", value)
end

--- wraps in a confirm dialog, accept fn of a text button or options of a button
---@param fn (function)
---@return any
local function confirm(fn, message, width)
    return function() return form.openDialog({
        title=string.format(__("confirmTitle")),
        message=message,
        width=width,
        buttons={
            {label=__("no"), action=function() return true end},
            {label=__("yes"), action=function() return fn() or true end},
        },
        options=TEXT_LEFT
    }) end
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
for i=0,24, 1 do
    local r,g,b,a = lcd.unRGB(lcd.themeColor(i))
    print(string.format("Theme %s #%02x%02x%02x%02x", i, r, g, b, a))
end
 ]]

return {
    isSensor=isSensor,
    isTimer=isTimer,
    sourceExists=sourceExists,
    replaceUTF8=replaceUTF8,
    bestFit=bestFit,
    bestOverlap=bestOverlap,
    formatWithDecimals=formatWithDecimals,
    confirm = confirm
}
