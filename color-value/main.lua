local scriptVersion = "1.1.2-rc4"
local scriptAuthor = "github.com/flyingeek"
local githubRepo = "ethos-color-value"
local refreshRate = 1 / 10 -- 10Hz
local defaultShowMinMax = true
local WIDGET_TYPE_SOURCE = 1
local WIDGET_TYPE_SENSOR = 2
local ethosVersion = system.getVersion()
local runningInSimulator = ethosVersion.simulation
-- widget backgrounds THEME_SECONDARY_BGCOLOR is inconsistent (light vs darkMode) and for Ethos 1.6 ETHOS constants are not exported
local widgetBgColorDark = ethosVersion.major >= 26 and lcd.RGB(0x28, 0x30, 0x38) or lcd.RGB(0x29, 0x29, 0x29)
local widgetBgColorLight = ethosVersion.major >= 26 and lcd.RGB(0xD6, 0xD6, 0xD6) or lcd.RGB(0xF6, 0xF3, 0xF7)
local widgetMargin = 4
local widgetTitleFont = FONT_S
local valueFonts = { FONT_XXL, FONT_XL, FONT_L, FONT_M or FONT_STD, FONT_S }
local minmaxFonts = { FONT_M or FONT_STD, FONT_S, FONT_XS }

system.compile("lib/init.lua")
local L = assert(loadfile("lib/init.luac", "b")({
    -- those parameters are accessible under the L namespace
    defaultSourcePrecision = 0,
    runningInSimulator = runningInSimulator,
    infoIcon = lcd.loadMask("bitmaps/icon_info.png"),
    deleteIcon = lcd.loadMask("bitmaps/mask_delete_icon.png"),
    isUTF8Compatible = ethosVersion.major >= 26,
    needsDialogReflow = not (ethosVersion.major >= 26 or (ethosVersion.major == 1 and ethosVersion.minor == 6 and ethosVersion.revision >= 6)),
    MAX_CONDITIONS = 5,       -- be careful for storage(read/write) if you change this
    secondaryColor = 0,       -- set in build
    defaultColor = 0,         -- set in build
    defaultWidgetBgColor = 0, -- set in build
}, "L"))                      -- here "L" is the namespace used in the lib files

local __ = L.translate
local log = L.log


---this is the create method for the Color Value Widget
---@return table
local function createTypeSource()
    local data = {
        -- configure parameters (saved in storage)
        source = nil,
        logics = L.LogicCases:new(),
        showTitle = true,
        showMinMax = defaultShowMinMax,
        type = WIDGET_TYPE_SOURCE,
        useBackgroung = false,
        useState = false,
        -- output values
        value = nil,
        minimum = nil,
        maximum = nil,
        telemetryState = nil,
        -- others
        timestamp = 0,           -- timestamp of last update per widget instance
        updateNextWakeup = true, -- when true, forces update of the widget in the next wakeup (used after configuration changes in write function or on init)
        -- computed parameters for paint (not saved in storage)
        width = nil,
        height = nil,
        matchingCaseIndex = nil,
        bgColor = nil,
        -- titleParameters
        titleLineHeight = 0,
        titleColor = 0,
        titles = {}, -- fixed mutable buffer
        -- valueParameters
        valueWidth = 0,
        valueHeight = 0,
        valueLineHeight = 0,
        valueFontIndex = 1,
        valueColor = 0,
        valueY = 0,
        values = {}, -- fixed mutable buffer
        -- minmax Parameters
        minmaxColor = 0,
        minmaxFontIndex = 1,
        minValueY = 0,
        minValueHeight = 0,
        minValueWidth = 0,
        maxValueHeight = 0,
        maxValueWidth = 0,
        formattedMinValue = "",
        formattedMaxValue = "",
    }
    lcd.font(widgetTitleFont)
    data.titleLineHeight = select(2, lcd.getTextSize("T"))
    return data
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

    local sourceField = form.addSourceField(line, nil,
        function()
            if widget.type == WIDGET_TYPE_SENSOR and widget.source == nil then
                widget.source = system.getSource({ category = CATEGORY_TELEMETRY_SENSOR })
            end
            return widget.source
        end,
        function(newValue)
            if newValue ~= widget.source then
                widget.source = newValue
                widget.logics = L.LogicCases:new(newValue)
                widget.showMinMax = defaultShowMinMax
                widget.updateNextWakeup = true
                form.clear()
                configure(widget)
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
        form.addBooleanField(line, nil, function() return widget.showMinMax end,
            function(newValue)
                widget.showMinMax = newValue
                widget.updateNextWakeup = true
            end)
    end
    line = form.addLine(__("showBackgroundColor"))
    form.addBooleanField(line, nil, function() return widget.useBackgroung end,
        function(newValue)
            widget.useBackgroung = newValue
            widget.updateNextWakeup = true
            L.fillLogicPanel(panel, widget, false)
        end)

    line = form.addLine(__("showCustomStates"))
    form.addBooleanField(line, nil, function() return widget.useState end,
        function(newValue)
            widget.useState = newValue
            widget.updateNextWakeup = true
            L.fillLogicPanel(panel, widget, false)
        end)

    line = form.addLine(__("showTitle"))
    form.addBooleanField(line, nil, function() return widget.showTitle end,
        function(newValue)
            widget.showTitle = newValue
            widget.updateNextWakeup = true
            L.fillLogicPanel(panel, widget, false)
        end)
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

local function updateParameters(widget)
    local clearIndex
    local matchingCase = widget.matchingCaseIndex and widget.logics:get(widget.matchingCaseIndex) or nil
    --- Background Color---
    if widget.useBackgroung and matchingCase then
        widget.bgColor = matchingCase.bgcolor
    else
        widget.bgColor = nil
    end
    --- TITLE ---
    local titles = widget.titles
    titles[1] = widget.source and widget.source:name() or "---"
    local titleCount = 0
    local titleHeight = 0
    if widget.showTitle then
        local titleColor = L.secondaryColor
        titleCount = 1
        titleHeight = widget.titleLineHeight
        if matchingCase then
            if widget.useBackgroung and widget.bgColor then
                titleColor = matchingCase.color
            end
            if widget.useState and matchingCase.title ~= "" then
                titleCount = 0
                titleHeight = 0
                L.parseTagsEach(matchingCase.title, widget.source, function(line)
                    titleCount = titleCount + 1
                    titleHeight = titleHeight + widget.titleLineHeight
                    titles[titleCount] = line
                end)
            end
        end
        widget.titleColor = titleColor
    end
    clearIndex = titleCount + 1
    while titles[clearIndex] ~= nil do
        titles[clearIndex] = nil
        clearIndex = clearIndex + 1
    end

    --- VALUE ---
    if not L.sourceExists(widget.source) then return end
    local fgColor = L.defaultColor
    local values = widget.values
    values[1] = widget.source:stringValue() or ""
    local valueCount = 1
    local w, h = widget.width or 0, widget.height or 0
    if matchingCase then
        fgColor = matchingCase.color
        if widget.useState and matchingCase.text ~= "" then
            valueCount = 0
            L.parseTagsEach(matchingCase.text, widget.source, function(line)
                valueCount = valueCount + 1
                values[valueCount] = line
            end)
        end
    end
    clearIndex = valueCount + 1
    while values[clearIndex] ~= nil do
        values[clearIndex] = nil
        clearIndex = clearIndex + 1
    end
    -- optimize by restricting lookup from current size - 2 to smallest size
    local searchIndex = widget.valueFontIndex or 1
    if searchIndex > 2 then
        searchIndex = searchIndex - 2
    elseif searchIndex > 1 then
        searchIndex = searchIndex - 1
    end
    widget.valueWidth, widget.valueHeight, widget.valueLineHeight, widget.valueFontIndex = L.bestFit(values, valueFonts,
        w - (widgetMargin * 2), h - widgetMargin - titleHeight, "0", searchIndex)
    widget.valueColor = fgColor
    widget.valueY = (widgetMargin + titleHeight - widget.valueHeight + h) / 2

    --- MIN/MAX ---
    if widget.showMinMax and L.isSensor(widget.source) and widget.minimum ~= nil and widget.maximum ~= nil then
        widget.formattedMinValue = L.formatWithDecimals(widget.minimum, widget.source) .. "↓"
        widget.formattedMaxValue = L.formatWithDecimals(widget.maximum, widget.source) .. "↑"
        local maxValueY = widgetMargin
        -- we want minValueY + minValueHeight < valueY and we consider minValueHeight == maxValueHeight
        local maxHeight = (widget.valueY / 2) - ((3 * widgetMargin) / 4)
        -- optimize by restricting lookup from current size - 1 to smallest size
        searchIndex = widget.minmaxFontIndex or 1
        if searchIndex > 1 then
            searchIndex = searchIndex - 1
        end
        local endSearchIndex = #minmaxFonts
        if widget.width >= 256 then
            endSearchIndex = endSearchIndex -
                1 -- restrict allowed fonts (no FONT_XS) for wide widgets for readability reasons
        end
        local minValueWidth, minValueHeight, bestFontIndex = L.bestOverlap(widget.formattedMinValue, minmaxFonts,
            (widget.width - widget.valueWidth) / 2, maxHeight, "0", searchIndex, endSearchIndex)
        local maxValueWidth, maxValueHeight = lcd.getTextSize(L.isUTF8Compatible and widget.formattedMaxValue or
            L.replaceUTF8(widget.formattedMaxValue, "0"))
        widget.minValueY = maxValueY + maxValueHeight + (widgetMargin / 2)
        widget.minValueHeight = minValueHeight
        widget.minValueWidth = minValueWidth
        widget.maxValueHeight = maxValueHeight
        widget.maxValueWidth = maxValueWidth
        widget.minmaxFontIndex = bestFontIndex
        widget.minmaxColor = widget.bgColor and fgColor or L.defaultColor
    end
end

local function wakeup(widget)
    local newTimestamp = os.clock()
    local enforceUpdate = widget.updateNextWakeup
    if widget.source and (enforceUpdate or newTimestamp >= widget.timestamp + refreshRate) then
        widget.timestamp = newTimestamp
        local newValue = widget.source:value()
        local newMinimum = widget.source:value({ options = OPTION_SENSOR_MIN })
        local newMaximum = widget.source:value({ options = OPTION_SENSOR_MAX })
        local newTelemetryState = widget.source:state()
        local telemetryChanged = widget.telemetryState ~= newTelemetryState and L.isSensor(widget.source)
        if enforceUpdate
            or widget.value ~= newValue
            or widget.minimum ~= newMinimum
            or widget.maximum ~= newMaximum
        then
            widget.value = newValue
            widget.minimum = newMinimum
            widget.maximum = newMaximum
            widget.matchingCaseIndex = widget.logics:matchIndex(newValue)
            updateParameters(widget)
            lcd.invalidate()
        end
        if enforceUpdate or telemetryChanged then
            widget.telemetryState = newTelemetryState
            lcd.invalidate() -- update colors if telemetry state changed
        end
        if enforceUpdate then widget.updateNextWakeup = false end
    end
end

local function paint(widget)
    if not L.sourceExists(widget.source) then return end
    local focusBgColor = lcd.darkMode() and lcd.themeColor(THEME_SECONDARY_BGCOLOR or THEME_FOCUS_BGCOLOR) or COLOR_WHITE
    local valueColor = widget.valueColor
    local titleColor = widget.titleColor
    local bgColor = widget.bgColor
    local minmaxColor = widget.minmaxColor
    if widget.telemetryState == false and widget.value ~= nil and L.isSensor(widget.source) then
        valueColor = lcd.themeColor(THEME_WARNING_COLOR)
        titleColor = L.secondaryColor
        bgColor = nil
        minmaxColor = L.defaultColor
    end
    local margin = widgetMargin
    local w, h = widget.width or 0, widget.height or 0
    local i, line
    if bgColor then
        if not lcd.hasFocus() and ((lcd.darkMode() and bgColor ~= widgetBgColorDark) or (not lcd.darkMode() and bgColor ~= widgetBgColorLight)) then
            lcd.color(bgColor)
            lcd.drawFilledRectangle(0, 0, w, h)
        end
    end
    if widget.showTitle then
        lcd.font(widgetTitleFont)
        lcd.color(lcd.hasFocus() and focusBgColor or titleColor)
        i = 1
        line = widget.titles[i]
        while line ~= nil do
            lcd.drawText(w / 2, margin + (i - 1) * widget.titleLineHeight, line, TEXT_CENTERED)
            i = i + 1
            line = widget.titles[i]
        end
    end

    local valueY = widget.valueY
    lcd.color(lcd.hasFocus() and focusBgColor or valueColor)
    lcd.font(valueFonts[widget.valueFontIndex])
    i = 1
    line = widget.values[i]
    while line ~= nil do
        lcd.drawText(w / 2, valueY + (i - 1) * widget.valueLineHeight, line, TEXT_CENTERED)
        i = i + 1
        line = widget.values[i]
    end

    -- Min/Max Values output
    lcd.color(lcd.hasFocus() and focusBgColor or minmaxColor)
    if widget.showMinMax and L.isSensor(widget.source) and widget.minimum ~= nil and widget.maximum ~= nil then
        local maxValueY = margin
        lcd.font(minmaxFonts[widget.minmaxFontIndex])
        lcd.drawText(w - margin, maxValueY, widget.formattedMaxValue, TEXT_RIGHT)
        lcd.drawText(w - margin, widget.minValueY, widget.formattedMinValue, TEXT_RIGHT)
        lcd.drawLine(
            w - margin - math.max(widget.maxValueWidth, widget.minValueWidth) - margin, --x1
            maxValueY + widget.maxValueHeight,                                          --y1
            w - margin,                                                                 --x2
            maxValueY + widget.maxValueHeight                                           --y2
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
    if value and type(value) == "string" and value ~= "" then
        widget.logics = L.LogicCases:new():loadStorageString(value)
        upgradeLogicsFromV1 = true
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
            for i = 1, widget.logics:count() do
                local logic = widget.logics:get(i)
                logic.title = value
            end
        end
    else
        for i = 1, L.MAX_CONDITIONS do
            value = storage.read(string.format("logic%s", i))
            if value and type(value) == "string" and value ~= "" then
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
    for i = 1, L.MAX_CONDITIONS do
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
                table.insert(menuData, {
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
                    openPageParameters = { timer = widget.source:member() }
                elseif L.isSensor(widget.source) then
                    openPageParameters = { sensor = widget.source:member() }
                end
                if openPageParameters then
                    table.insert(menuData, {
                        string.format(__("editMenuASCII"), widget.source:name()),
                        function() system.openPage(openPageParameters) end
                    })
                end
            end
            table.insert(menuData, {
                string.format(__("resetMenuASCII"), widget.source:name()),
                function()
                    widget.source:reset()
                    widget.value = nil
                end
            })
        end
    end
    return menuData
end

local function build(widget)
    local isDarkMode = lcd.darkMode()
    L.secondaryColor = lcd.themeColor(THEME_SECONDARY_COLOR or 14)
    L.defaultColor = lcd.themeColor(THEME_PRIMARY_COLOR or THEME_DEFAULT_COLOR)
    L.defaultWidgetBgColor = isDarkMode and widgetBgColorDark or widgetBgColorLight
    widget.width, widget.height = lcd.getWindowSize()
    local locale = system.getLocale()
    if system.getLocale() ~= L.getLocale() then
        L.changeLocale(locale)
    end
    widget.updateNextWakeup = true -- force update on next wakeup to apply colors and translations
end

local function init()
    system.registerWidget({
        key = "fgCVMM",
        name = nameTypeSource,
        create = createTypeSource,
        wakeup = wakeup,
        paint = paint,
        build = build,
        configure = configure,
        read = read,
        write = write,
        menu = menu,
        title = false
    })
    system.registerWidget({
        key = "fgCSMM",
        name = nameTypeSensor,
        create = createTypeSensor,
        wakeup = wakeup,
        paint = paint,
        build = build,
        configure = configure,
        read = read,
        write = write,
        menu = menu,
        title = false
    })
end

return { init = init }
