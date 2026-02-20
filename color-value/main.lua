local scriptVersion = "1.0.0"
local scriptAuthor = "github.com/flyingeek"
local githubName = "ethos-color-value"
local refreshRate = 1/10 -- 10Hz
local defaultShowMinMax = true
local WIDGET_TYPE_SOURCE = 1
local WIDGET_TYPE_SENSOR = 2
local ethosVersion = system.getVersion()
local runningInSimulator = ethosVersion.simulation

system.compile("lib/init.lua")
local L = assert(loadfile("lib/init.luac", "b")({
    -- those parameters are accessible under the L namespace
    defaultSourcePrecision = 0,
    infoIcon = lcd.loadMask("bitmaps/icon_info.png"),
    deleteIcon = lcd.loadMask("bitmaps/mask_delete_icon.png"),
    isUTF8Compatible=tonumber(ethosVersion.major .. ethosVersion.minor) >= 17
}, "L")) -- here "L" is the namespace used in the lib files

local __ = L.translate

local function createTypeSource()
     return {
        -- configure parameters (saved in storage)
        source=nil,
        logics=L.LogicCases:new(),
        showTitle=true,
        showMinMax=defaultShowMinMax,
        type=WIDGET_TYPE_SOURCE,
        -- output values
        value=nil,
        minimum=nil,
        maximum=nil,
        telemetryState=nil,
        -- others
        timestamp = 0 -- timestamp of last update per widget instance
     }
end
local function createTypeSensor()
    local data = createTypeSource()
    data.type = WIDGET_TYPE_SENSOR
    return data
end

local function nameTypeSource()
    return __("widgetNameTypeSourceASCII")
end
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
    if not L.sourceExists(widget.source) then
        sourceField:focus()
    else
        local panel = form.addExpansionPanel(__("logicPanel"))
        L.fillLogicPanel(panel, widget)
    end
    if L.isSensor(widget.source) then
        line = form.addLine(__("showMinMax"))
        form.addBooleanField(line, nil, function() return widget.showMinMax end, function(newValue) widget.showMinMax = newValue end)
    end
    line = form.addLine(__("showTitle"))
    form.addBooleanField(line, nil, function() return widget.showTitle end, function(newValue) widget.showTitle = newValue end)
    local panel = form.addExpansionPanel(__("infoPanelTitle"))
    panel:open(false)
    line = panel:addLine(__("infoPanelWidgetName"))
    form.addStaticText(line, nil, githubName)
    line = panel:addLine(__("infoPanelVersion"))
    form.addStaticText(line, nil, scriptVersion)
    line = panel:addLine(__("infoPanelAuthor"))
    form.addStaticText(line, nil, scriptAuthor)
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
    local titleColor = lcd.hasFocus() and lcd.themeColor(THEME_FOCUS_BGCOLOR) or lcd.themeColor(14)
    local defaultColor = lcd.hasFocus() and lcd.themeColor(THEME_FOCUS_BGCOLOR) or lcd.themeColor(THEME_DEFAULT_COLOR)
    local warningColor = lcd.themeColor(THEME_WARNING_COLOR)
    local _
    local titleHeight = 0
    local margin = 4
    local w, h = lcd.getWindowSize()

    if widget.showTitle then
        lcd.font(FONT_S)
        lcd.color(titleColor)
        _, titleHeight = lcd.getTextSize("") -- adjust TitleHeight
        lcd.drawText(w/2, margin , widget.source and widget.source:name() or "---", TEXT_CENTERED)
    end

    if not L.sourceExists(widget.source) then return end
    --
    -- The code below has a valid widget.source
    --
    -- Source Value output
    -- find and set best font size for the widget's size
    local valueWidth, valueHeight = L.bestFit(widget.source:stringValue(), {FONT_XXL, FONT_XL, FONT_STD}, w - (margin * 2))
    local valueY = (margin + titleHeight - valueHeight + h) / 2
    -- choose color using Default Color, Logic Color or Telemetry Lost Color
    lcd.color(defaultColor)
    local matchingCase = widget.logics:match(widget.value)
    if matchingCase then
        lcd.color(matchingCase.color)
    end
    if widget.value ~= nil and widget.telemetryState == false and L.isSensor(widget.source) then -- telemetry lost
        lcd.color(warningColor)
    end
    lcd.drawText(w/2, valueY, widget.source:stringValue(), TEXT_CENTERED)

    -- Min/Max Values output
    if widget.showMinMax and L.isSensor(widget.source) and widget.minimum ~= nil and widget.maximum ~= nil then
        local formattedMinValue = L.formatWithDecimals(widget.minimum, widget.source).."↓"
        local formattedMaxValue = L.formatWithDecimals(widget.maximum, widget.source).."↑"
        local maxValueY = margin
        -- we want minValueY + minValueHeight < valueY and we consider minValueHeight == maxValueHeight
        local maxHeight = (valueY/2) - ((3 * margin)/4)
        -- find and set best font size for the widget's size
        local minValueWidth, minValueHeight = L.bestOverlap(formattedMinValue, {FONT_STD, FONT_S}, (w - valueWidth)/2 , maxHeight, "0")
        local maxValueWidth, maxValueHeight = lcd.getTextSize(L.isUTF8Compatible and formattedMaxValue or L.replaceUTF8(formattedMaxValue, "0"))
        local minValueY = maxValueY + maxValueHeight + (margin/2)
        lcd.color(defaultColor)
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
    widget.source = storage.read("source")
    widget.showTitle = storage.read("showTitle")
    widget.logics = L.LogicCases:new():loadStorageString(storage.read("logics") or "")
    widget.showMinMax = storage.read("showMinMax")
    widget.type = storage.read("type")
end

local function write(widget)
    --print("storage.write")
    storage.write("source", widget.source)
    storage.write("showTitle", widget.showTitle)
    storage.write("logics", widget.logics:asStorageString())
    --print(string.format("logics: %s", widget.logics:asStorageString()))
    storage.write("showMinMax", widget.showMinMax)
    storage.write("type", widget.type)
end

local function menu(widget)
    local menuData = {}
    if widget.source and widget.source.reset then
        if L.isSensor(widget.source) then
            table.insert(menuData, {
                    string.format(__("minimumMenuASCII"), L.formatWithDecimals(widget.source:minimum(), widget.source), widget.source:stringUnit()),
                    function() end
                })
            table.insert(menuData,{
                    string.format(__("maximumMenuASCII"), L.formatWithDecimals(widget.source:maximum(), widget.source), widget.source:stringUnit()),
                    function() end
                })
        end
        if L.isSensor(widget.source) or L.isTimer(widget.source) then
            table.insert(menuData,{
                string.format(__("resetMenuASCII"), widget.source:name()),
                function() widget.source:reset() widget.value = nil end
            })
        end
    end
    return menuData
end

local function init()
 system.registerWidget({key="fgCVMM", name=nameTypeSource, create=createTypeSource, wakeup=wakeup, paint=paint, configure=configure,  read=read, write=write, menu=menu, title=false})
 system.registerWidget({key="fgCSMM", name=nameTypeSensor, create=createTypeSensor, wakeup=wakeup, paint=paint, configure=configure,  read=read, write=write, menu=menu, title=false})
end

return {init=init}
