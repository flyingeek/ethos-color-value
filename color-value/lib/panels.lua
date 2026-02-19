---@diagnostic disable-next-line: undefined-global
local L = L
local __ = L.translate

local function fillLogicPanel(panel, widget)
    if panel == nil then return end
    local choices = {{" <= ", L.OPE_LESS_OR_EQUAL}, {" < ", L.OPE_LESS}, {" > ", L.OPE_MORE}, {" >= ", L.OPE_MORE_OR_EQUAL}}
    local maxConditions = 5
    local line
    local slots
    local count = #(widget.logics)
    local dialogWidth = math.floor(lcd.getWindowSize() * 0.9)
    local confirmDialogWidth = math.floor(math.min(400, lcd.getWindowSize() * 0.8))
    panel:clear()
    -- the conditionLabel "If sourcename" is shared with all logic case
    local conditionLabel = L.sourceExists(widget.source) and widget.source:name() or ""
    if conditionLabel ~= "" then conditionLabel = string.format(__("conditionLabel"), conditionLabel) end
    local caseTexts = {} -- a list of all the "Case%d" staticTextField
    -- delete the logic case @index
    local function doDelete(index)
        table.remove(widget.logics, index)
        model.dirty() -- triggers the write widget method
    end
    -- adds a logic case
    local function doAdd()
        local newLogic = L.LogicCase:new()
        if count >= 1 then
            newLogic.ope = widget.logics[count].ope
            newLogic.threshold = widget.logics[count].threshold
        end
        table.insert(widget.logics, newLogic)
        model.dirty()
    end
    -- hightlight or normalizes all the case based on the logic conditions
    local function highlightValidCase()
        local hasMatch = false
        local defaultColor = lcd.themeColor(14)
        local highlightColor = lcd.darkMode() and lcd.themeColor(THEME_DEFAULT_COLOR) or lcd.color(BLACK)
        for j, staticText in pairs(caseTexts) do
            if hasMatch == false and widget.logics[j]:test(widget.value) then
                staticText:color(highlightColor)
                hasMatch = true -- only the first match
            else
                staticText:color(defaultColor)
            end
        end
    end
    for i, logic in pairs(widget.logics) do
        line = panel:addLine("", i == count and count >= maxConditions)
        -- "Case%d" at the beginning of the line as a staticText to be able to colorize it
        local caseLabel = string.format(__("case"), i)
        slots = form.getFieldSlots(line, {caseLabel, 0})
        caseTexts[i] = form.addStaticText(line , {x=0, y=slots[1].y, w=slots[1].w, h=slots[1].h}, caseLabel)
        -- "If sourceName" at left of FieldSlots
        slots = form.getFieldSlots(line, {conditionLabel, 0})
        local conditionLabelWidth = slots[1].w
        form.addStaticText(line , {x=slots[1].x - conditionLabelWidth - 10, y=slots[1].y, w=conditionLabelWidth, h=slots[1].h}, conditionLabel)
        -- "DELETE" at left of "If sourceName" is wrapped in a confirm dialog
        form.addButton(line,
            {x=slots[1].x - conditionLabelWidth - 10 - 50 - 10, y=slots[1].y, w=50, h=slots[1].h}, -- rect
            {
                icon=L.deleteIcon,
                press=function ()
                    return form.openDialog({
                        title=string.format(__("caseDeleteTitle"), i),
                        message=string.format(__("caseDeleteMessage"), i),
                        width=confirmDialogWidth,
                        buttons={
                            {label=__("no"), action=function() return true end},
                            {label=__("yes"), action=function() doDelete(i) return fillLogicPanel(panel, widget) or true end}},
                        options=TEXT_LEFT
                    })
                end
            }
        )
        -- now we can use the auto positionning for the operator, the threshold and the color
        slots = form.getFieldSlots(line, {90, 0, 70})
        form.addChoiceField(line, slots[1], choices,
            function() return widget.logics[i].ope end,
            function(newValue) widget.logics[i].ope = newValue return highlightValidCase() end
        ):focus()
        local factoredField = L.addFactoredNumberField(line, slots[2], 0, 0, -- no need to care about min and max here
            function() return widget.logics[i].threshold end,
            function(newValue) widget.logics[i].threshold = newValue return highlightValidCase() end
        )
        factoredField.updateFromSource(widget.source)
        form.addColorField(line, slots[3], function() return widget.logics[i].color end, function(newValue) widget.logics[i].color = newValue end)
    end
    highlightValidCase()
    if count < maxConditions and widget.source ~= nil and widget.source:name()~="---" then
        line = panel:addLine("")
        -- info position is non standard, left of the fieldSlots
        slots = form.getFieldSlots(line, {0})
        form.addButton(line,
            {x=slots[1].x - 50 - 10, y=slots[1].y, w=50, h=slots[1].h}, --rect
            { -- a button to open the help dialog
                icon=L.infoIcon,
                paint=function() end,
                press=function()
                    return form.openDialog({
                        title=__("help"),
                        message=__("helpMessage"),
                        width=dialogWidth,
                        buttons={{label=__("ok"), action=function() return true end}},
                        options=TEXT_LEFT,
                        closeWhenClickOutside=true
                    })
                end
            }
        )
        -- auto positionned Add button
        local addButton = form.addButton(line, nil, {text="+", press=function() doAdd() return fillLogicPanel(panel, widget) end})
        if count == 0 then
            addButton:focus()
        end
    end
end

return {
    fillLogicPanel=fillLogicPanel
}
