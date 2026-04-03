local scriptVersion = "1.1.1"
local scriptAuthor = "github.com/flyingeek"
local githubRepo = "ethos-color-value"
local refreshRate = 1/10 -- 10Hz
local defaultShowMinMax = true
local WIDGET_TYPE_SOURCE = 1
local WIDGET_TYPE_SENSOR = 2
local ethosVersion = system.getVersion()
local runningInSimulator = ethosVersion.simulation
-- widget backgrounds
local widgetBgColorDark = tonumber(ethosVersion.major .. ethosVersion.minor) >= 261 and lcd.RGB(40, 48, 56) or lcd.RGB(0x29, 0x28, 0x29)
local widgetBgColorLight = tonumber(ethosVersion.major .. ethosVersion.minor) >= 261 and lcd.RGB(214, 214, 214) or lcd.RGB(0xF6, 0xF3, 0xF7)


system.compile("lib/init.lua")
local L = assert(loadfile("lib/init.luac", "b")({
    -- those parameters are accessible under the L namespace
    defaultSourcePrecision = 0,
    infoIcon = lcd.loadMask("bitmaps/icon_info.png"),
    deleteIcon = lcd.loadMask("bitmaps/mask_delete_icon.png"),
    isUTF8Compatible=tonumber(ethosVersion.major .. ethosVersion.minor) >= 17,
    MAX_CONDITIONS = 5, -- be careful for storage(read/write) if you change this
    defaultWidgetTitleColor = lcd.RGB(0xB0, 0xB0, 0xB0),
    defaultColor = lcd.RGB(0xF8, 0xFC, 0xF8),
    defaultBgColor = lcd.RGB(0x20, 0x20, 0x20),
    defaultWidgetBgColor = widgetBgColorDark
}, "L")) -- here "L" is the namespace used in the lib files

local __ = L.translate
local log = L.log


---this is the create method for the Color Value Widget
---@return table
local function createTypeSource()
     return {
        -- configure parameters (saved in storage)
        source=nil,
        logics=L.LogicCases:new(),
        showTitle=true,
        showMinMax=defaultShowMinMax,
        type=WIDGET_TYPE_SOURCE,
        useBackgroung=false,
        useState=false,
        -- output values
        value=nil,
        minimum=nil,
        maximum=nil,
        telemetryState=nil,
        -- others
        timestamp = 0 -- timestamp of last update per widget instance
     }
end

---this is the create method for the Telemetry Value Widget
---@return table
local function createTypeSensor()
    local data = createTypeSource()
    data.type = WIDGET_TYPE_SENSOR
    return data
end

---this is the name method of the Color Value widget
---@return string
local function nameTypeSource()
    return __("widgetNameTypeSourceASCII")
end
---this is the name method of the Telemetry Value widget
---@return string
local function nameTypeSensor()
    return __("widgetNameTypeSensorASCII")
end

local function configure(widget)
    local line = form.addLine(__("source"))
    local method = widget.type == WIDGET_TYPE_SOURCE and "addSourceField" or "addSensorField"
    local sourceField = form[method](line, nil,
        function() return widget.source end,
        function(newValue)
            if newValue ~= widget.source then
                widget.source =  newValue
                widget.logics = L.LogicCases:new(newValue)
                widget.showMinMax = defaultShowMinMax
                form.clear()
                return configure(widget) --tail call
            end
        end
    )
    local panel
    if not L.sourceExists(widget.source) then
        sourceField:focus()
    else
        panel = form.addExpansionPanel(__("logicPanel"))
        L.fillLogicPanel(panel, widget)
    end
    if L.isSensor(widget.source) then
        line = form.addLine(__("showMinMax"))
        form.addBooleanField(line, nil, function() return widget.showMinMax end, function(newValue) widget.showMinMax = newValue end)
    end
    line = form.addLine(__("showBackgroundColor"))
    form.addBooleanField(line, nil, function() return widget.useBackgroung end, function(newValue) widget.useBackgroung = newValue L.fillLogicPanel(panel, widget, false) end)

    line = form.addLine(__("showCustomStates"))
    form.addBooleanField(line, nil, function() return widget.useState end, function(newValue) widget.useState = newValue  L.fillLogicPanel(panel, widget, false) end)

    line = form.addLine(__("showTitle"))
    form.addBooleanField(line, nil, function() return widget.showTitle end, function(newValue) widget.showTitle = newValue L.fillLogicPanel(panel, widget, false) end)
    local panel = form.addExpansionPanel(__("infoPanelTitle"))
    panel:open(false)
    line = panel:addLine(__("infoPanelGitHubRepo"))
    form.addStaticText(line, nil, githubRepo)
    line = panel:addLine(__("infoPanelVersion"))
    form.addStaticText(line, nil, scriptVersion)
    line = panel:addLine(__("infoPanelAuthor"))
    form.addStaticText(line, nil, scriptAuthor)
    widget.focus = nil
end

local function wakeup(widget)
    local newTimestamp = os.clock()
    if widget.source and newTimestamp >= widget.timestamp + refreshRate then
        widget.timestamp = newTimestamp
        local newValue = widget.source:value()
        local newMinimum = widget.source:value({options=OPTION_SENSOR_MIN})
        local newMaximum = widget.source:value({options=OPTION_SENSOR_MAX})
        local newTelemetryState = widget.source:state()
        if widget.value ~= newValue or widget.minimum ~= newMinimum or widget.maximum ~= newMaximum then
            widget.value = newValue
            widget.minimum = newMinimum
            widget.maximum = newMaximum
            lcd.invalidate()
        end
        if widget.telemetryState ~= newTelemetryState and L.isSensor(widget.source) then
            widget.telemetryState = newTelemetryState
            lcd.invalidate()
        end
    end
end

local function paint(widget)
    local textFocusBgColor = lcd.darkMode() and lcd.themeColor(THEME_FOCUS_BGCOLOR) or lcd.color(COLOR_WHITE)
    local titleColor = lcd.hasFocus() and textFocusBgColor or L.defaultWidgetTitleColor
    local defaultColor = lcd.hasFocus() and textFocusBgColor or L.defaultColor
    local warningColor = lcd.themeColor(THEME_WARNING_COLOR)
    local _
    local titleHeight = 0
    local margin = 4
    local w, h = lcd.getWindowSize()

    if not L.sourceExists(widget.source) then return end
    --
    -- The code below has a valid widget.source
    --

    -- Source Value output
    --
    -- choose color using Default Color, Logic Color or Telemetry Lost Color
    local fgColor = defaultColor
    local minmaxColor = defaultColor
    local mayUseBackground = false
    local matchingCase = widget.logics:match(widget.value)
    local outputValues
    if widget.useState and matchingCase and matchingCase.text~="" then
        outputValues = matchingCase:getText(widget.source)
    else
        outputValues = {widget.source:stringValue()}
    end
    if widget.value ~= nil and widget.telemetryState == false and L.isSensor(widget.source) then -- telemetry lost
        fgColor = warningColor
    elseif matchingCase then
        fgColor = matchingCase.color
        if widget.useBackgroung and matchingCase.bgcolor and not lcd.hasFocus() then
            titleColor = matchingCase.color
            mayUseBackground = true
        end
    end
    if mayUseBackground and matchingCase.bgcolor then

        if (lcd.darkMode() and matchingCase.bgcolor ~= widgetBgColorDark) or (not lcd.darkMode() and  matchingCase.bgcolor ~= widgetBgColorLight) then
            lcd.color(matchingCase.bgcolor)
            lcd.drawFilledRectangle(0, 0, w, h)
            minmaxColor = matchingCase.fgColor
        end
    end
    if widget.showTitle then
        lcd.font(FONT_S)
        lcd.color(titleColor)
        local titles
        if widget.useState and matchingCase and matchingCase.title ~= "" then
            titles = matchingCase:getTitle(widget.source)
        else
            titles = {widget.source and widget.source:name() or "---"}
        end
        for _, line in pairs(titles) do
            local _, h = lcd.getTextSize(line)
            lcd.drawText(w/2, margin + titleHeight, line, TEXT_CENTERED)
            titleHeight = titleHeight + h
        end
    end
    -- find and set best font size for the widget's size
    local valueWidth, valueHeight, lineHeight = L.bestFit(outputValues, {FONT_XXL, FONT_XL, FONT_STD}, w - (margin * 2), h - margin - titleHeight)
    local valueY = (margin + titleHeight - valueHeight + h) / 2

    lcd.color(lcd.hasFocus() and defaultColor or fgColor)
    for i, line in pairs(outputValues) do
        lcd.drawText(w/2, valueY + (i - 1) * lineHeight, line, TEXT_CENTERED)
    end

    -- Min/Max Values output
    lcd.color(lcd.hasFocus() and defaultColor or minmaxColor)
    if widget.showMinMax and L.isSensor(widget.source) and widget.minimum ~= nil and widget.maximum ~= nil then
        local formattedMinValue = L.formatWithDecimals(widget.minimum, widget.source).."↓"
        local formattedMaxValue = L.formatWithDecimals(widget.maximum, widget.source).."↑"
        local maxValueY = margin
        -- we want minValueY + minValueHeight < valueY and we consider minValueHeight == maxValueHeight
        local maxHeight = (valueY/2) - ((3 * margin)/4)
        -- find and set best font size for the widget's size
        local allowedSize = w < 256 and {FONT_STD, FONT_S, FONT_XS} or {FONT_STD, FONT_S}
        local minValueWidth, minValueHeight = L.bestOverlap(formattedMinValue, allowedSize, (w - valueWidth)/2 , maxHeight, "0")
        local maxValueWidth, maxValueHeight = lcd.getTextSize(L.isUTF8Compatible and formattedMaxValue or L.replaceUTF8(formattedMaxValue, "0"))
        local minValueY = maxValueY + maxValueHeight + (margin/2)
        lcd.drawText(w - margin, maxValueY, formattedMaxValue, TEXT_RIGHT)
        lcd.drawText(w - margin, minValueY, formattedMinValue, TEXT_RIGHT)
        lcd.drawLine(
            w - margin - math.max(maxValueWidth, minValueWidth) - margin, --x1
            maxValueY + maxValueHeight,--y1
            w - margin,--x2
            maxValueY + maxValueHeight --y2
        )
    end
end

local function read(widget)
    local value
    local upgradeLogicsFromV1 = false
    widget.source = storage.read("source")
    widget.showTitle = storage.read("showTitle")
    -- backward compatibility v1
    value = storage.read("logics")
    if value and type(value) == "string" and value ~="" then
        widget.logics = L.LogicCases:new():loadStorageString(value)
        upgradeLogicsFromV1 =true
    end
    widget.showMinMax = storage.read("showMinMax")
    widget.type = storage.read("type")
    -- version 1.1
    value = storage.read("useBackgroung")
    if value ~= nil then widget.useBackgroung = value end
    value = storage.read("useState")
    if value ~= nil then widget.useState = value end
    -- due to string length restriction we had to split logics in 5 stores
    if upgradeLogicsFromV1 then
        -- this is an upgrade for title of 1.1.0-rc1 and 1.1.0-rc2
        value = storage.read("title")
        if type(value) == "string" then
            for i=1,widget.logics:count() do
                local logic = widget.logics:get(i)
                logic.title = value
            end
        end
    else
        for i=1,L.MAX_CONDITIONS do
            value = storage.read(string.format("logic%s", i))
            if value and type(value) == "string" and value ~="" then
                widget.logics:add(L.LogicCase:new():loadStorageString(value))
            end
        end
    end
end

local function write(widget)
    storage.write("source", widget.source)
    storage.write("showTitle", widget.showTitle)
    storage.write("logics", "") -- erase v1 storage as of 1.1.0-rc3
    storage.write("showMinMax", widget.showMinMax)
    storage.write("type", widget.type)
    -- version 1.1 rc1
    storage.write("useBackgroung", widget.useBackgroung)
    storage.write("useState", widget.useState)
    -- version 1.1 rc3
    for i=1,L.MAX_CONDITIONS do
        if widget.logics then
            local logic = widget.logics:get(i)
            if logic then
                storage.write(string.format("logic%s", i), logic:asStorageString())
            else
                storage.write(string.format("logic%s", i), "")
            end
        end
    end
end

local function menu(widget)
    local menuData = {}
    if widget.source and widget.source.reset then
        if not widget.showMinMax and L.isSensor(widget.source) then
            if widget.minimum then
                table.insert(menuData, {
                        string.format(__("minimumMenuASCII"),
                        L.formatWithDecimals(widget.minimum, widget.source),
                        widget.source:stringUnit()),
                        function() end
                    })
            end
            if widget.maximum then
                table.insert(menuData,{
                        string.format(__("maximumMenuASCII"),
                        L.formatWithDecimals(widget.maximum, widget.source),
                        widget.source:stringUnit()),
                        function() end
                    })
            end
        end
        if L.isSensor(widget.source) or L.isTimer(widget.source) then
            local openPageParameters
            if tonumber(ethosVersion.major .. ethosVersion.minor) >= 26 then
                if L.isTimer(widget.source) then
                    openPageParameters = {timer=widget.source:member()}
                elseif L.isSensor(widget.source) then
                    openPageParameters = {sensor=widget.source:member()}
                end
                if openPageParameters then
                    table.insert(menuData,{
                        string.format(__("editMenuASCII"), widget.source:name()),
                        function() system.openPage(openPageParameters) end
                    })
                end
            end
            table.insert(menuData,{
                string.format(__("resetMenuASCII"), widget.source:name()),
                function() widget.source:reset() widget.value = nil end
            })
        end
    end
    return menuData
end

local function build(widget)
    local isDarkMode = lcd.darkMode()
    L.defaultWidgetTitleColor = isDarkMode and lcd.RGB(0xB0, 0xB0, 0xB0) or lcd.RGB(0x58, 0x54, 0x58)
    L.defaultColor = isDarkMode and lcd.RGB(0xF8, 0xFC, 0xF8) or lcd.RGB(0x58, 0x54, 0x58)
    L.defaultBgColor = isDarkMode and lcd.RGB(0x20, 0x20, 0x20) or lcd.RGB(0xF0, 0xF0, 0xF0)
    L.defaultWidgetBgColor = isDarkMode and widgetBgColorDark or widgetBgColorLight

    local locale = system.getLocale()
    if system.getLocale() ~= L.getLocale() then
        L.changeLocale(locale)
    end
end

local function init()
 system.registerWidget({key="fgCVMM", name=nameTypeSource, create=createTypeSource, wakeup=wakeup, paint=paint, build=build, configure=configure,  read=read, write=write, menu=menu, title=false})
 system.registerWidget({key="fgCSMM", name=nameTypeSensor, create=createTypeSensor, wakeup=wakeup, paint=paint, build=build, configure=configure,  read=read, write=write, menu=menu, title=false})
end

return {init=init}
