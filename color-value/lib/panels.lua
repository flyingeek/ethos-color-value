---@diagnostic disable-next-line: undefined-global
local L = L
local __ = L.translate

local function positionLabel(line, x, label, color)
    local slots = form.getFieldSlots(line, {L.replaceUTF8(label, "e"), 0})
    if x == nil then x = slots[1].x - slots[1].w - 10 end
    local rect = slots[1]
    rect.x = x
    local field = form.addStaticText(line , rect, label)
    if color then field:color(color) end
    return field, rect
end
local function fillLogicPanel(panel, widget, grabFocus)
    local grayColor = L.defaultWidgetTitleColor
    local lcdWidth = system.getVersion().lcdWidth
    if panel == nil then return end
    if grabFocus == nil then grabFocus = true end

    local function appendTag(index, tag, method)
        local logic = widget.logics:get(index)
        if logic then
            L.LogicCase[method](logic, " " .. tag)
            model.dirty()
            fillLogicPanel(panel, widget)
        end
    end
    local function buildTagButtons(i, method)
        local buttons = {}
        if lcdWidth >= 800 then
            table.insert(buttons,
                {label=" _b ", action=function() appendTag(i, "_b", method) return true end}
            )
        end
        if widget.source.decimals and widget.source:decimals() then
            local k = 0
            local precision = widget.source:decimals()
            local j = precision
            while k < 2 and j >= 0 do
                local tag = "_"..tostring(j).."v"
                if j ~= precision then
                    table.insert(buttons,
                        {label=string.format("%."..tostring(j).."f", widget.source:value() or 0, widget.source), action=function() appendTag(i, tag, method) return true end}
                    )
                else
                    table.insert(buttons,
                        {label=string.format("%."..tostring(j).."f", widget.source:value() or 0, widget.source), action=function() appendTag(i, "_v", method) return true end}
                    )
                end
                k = k + 1
                j = j - 1
            end
        end
        local stringValue = widget.source:stringValue() == "---" and L.formatWithDecimals(0, widget.source)..widget.source:stringUnit() or widget.source:stringValue()
        table.insert(buttons, {label=stringValue:sub(1, 10), action=function() appendTag(i, "_t", method) return true end})
        table.insert(buttons, {label=widget.source:name(), action=function() appendTag(i, "_n", method) return true end})
        table.insert(buttons, {label=__("ok"), action=function() return true end})
        return buttons
    end
    local dialogWidth = math.floor(lcd.getWindowSize() * 0.9)
    local tagButtonText = "  ...  "
    local function addTagButton(line, rect, i, method)
        return form.addButton(line, rect,
            { -- tag dialog
                text=tagButtonText,
                paint=function() end,
                press=function()
                    return form.openDialog({
                        title=__("helpTagsTitle"),
                        message=__("helpTags"),
                        width=dialogWidth,
                        buttons=buildTagButtons(i, method),
                        options=TEXT_LEFT,
                        closeWhenClickOutside=true
                    })
                end
            })
    end
    local choices = {
        {L.isUTF8Compatible and " ≤ " or " <= ", L.OPE_LESS_OR_EQUAL},
        {" < ", L.OPE_LESS},
        {" = ", L.OPE_EQUAL},
        {" > ", L.OPE_MORE},
        {L.isUTF8Compatible and " ≥ " or" >= ", L.OPE_MORE_OR_EQUAL}}
    local maxConditions = L.MAX_CONDITIONS
    local line
    local slots
    local count = widget.logics:count()
    local confirmDialogWidth = math.floor(math.min(400, lcd.getWindowSize() * 0.8))
    local colorWidth = 71
    local choiceWidth = 95
    local maxDialogChars = 57
    if lcdWidth <= 480 then colorWidth = 50 choiceWidth = 60 maxDialogChars = 50
    elseif lcdWidth <= 640 then colorWidth = 64 choiceWidth = 80 maxDialogChars = 50 end
    panel:clear()
    -- the conditionLabel "If sourcename" is shared with all logic case
    local conditionLabel = L.sourceExists(widget.source) and widget.source:name() or ""
    if conditionLabel ~= "" then conditionLabel = string.format(__("conditionLabel"), conditionLabel) end
    local caseTexts = {} -- a list of all the "Case%d" staticTextField
    -- hightlight or normalizes all the case based on the logic conditions
    local function highlightValidCase()
        local highlightColor = lcd.RGB(0x88, 0xC0, 0x18)
        local match = widget.logics:matchIndex(widget.value)
        for j, staticText in pairs(caseTexts) do
            staticText:color(j == match and highlightColor or grayColor)
        end
    end
    if widget.useBackgroung and count > 0 then
        -- adds a line to indicate which color is which
        local explanation = __("colorHint")
        line = panel: addLine("", false)
        slots = form.getFieldSlots(line, {0, explanation})
        form.addStaticText(line , slots[2], explanation):color(grayColor)
    end
    local choiceField -- the last choice
    local textField -- the last textField
    for i=1,count do
        line = panel:addLine("", i == count and count >= maxConditions and not(widget.useBackgroung or widget.useState))
        -- "Case%d" at the beginning of the line as a staticText to be able to colorize it
        caseTexts[i] = positionLabel(line, 0, string.format(__("case"), i))
        -- "If sourceName" at left of FieldSlots
        local _, rect = positionLabel(line, nil, conditionLabel)
       -- "DELETE" at left of "If sourceName" is wrapped in a confirm dialog
        form.addButton(line,
            {x=rect.x - 50 - 10, y=rect.y, w=50, h=rect.h},
            {
                icon=L.deleteIcon,
                press=L.confirm(
                    function() widget.logics:remove(i) model.dirty() fillLogicPanel(panel, widget) end,
                    string.format(__("caseDeleteMessage"), i),
                    confirmDialogWidth
                )
            }
        )
        if widget.useBackgroung and lcdWidth >= 800 then
            slots = form.getFieldSlots(line, {choiceWidth, 0, colorWidth, colorWidth})
        elseif widget.useBackgroung then
            slots = form.getFieldSlots(line, {choiceWidth, 0})
        else
            slots = form.getFieldSlots(line, {choiceWidth, 0, colorWidth})
        end
        choiceField = form.addChoiceField(line, slots[1], choices,
            function() return widget.logics:get(i).ope end,
            function(newValue) widget.logics:get(i).ope = newValue return highlightValidCase() end
        )

        local factoredField = L.addFactoredNumberField(line, slots[2], 0, 0, -- no need to care about min and max here
            function() return widget.logics:get(i).threshold end,
            function(newValue) widget.logics:get(i).threshold = newValue return highlightValidCase() end
        )
        factoredField.updateFromSource(widget.source)

        if widget.useBackgroung and lcdWidth >= 800 then
            -- large screen both colors on condiftion line
            form.addColorField(line, slots[3],
                function() return widget.logics:get(i).color end,
                function(newValue) widget.logics:get(i).color = newValue end)
            form.addColorField(line, slots[4],
                function() return widget.logics:get(i).bgcolor or L.defaultWidgetBgColor end,
                function(newValue) widget.logics:get(i).bgcolor = newValue end)
        elseif widget.useBackgroung then
            -- small screen both colors on new line
            line = panel:addLine("", i == count and count >= maxConditions and not widget.useState)
            slots = form.getFieldSlots(line, {0, 0})
            form.addColorField(line, slots[1],
                function() return widget.logics:get(i).color end,
                function(newValue) widget.logics:get(i).color = newValue end)
            form.addColorField(line, slots[2],
                function() return widget.logics:get(i).bgcolor end,
                function(newValue) widget.logics:get(i).bgcolor = newValue end)
        else
            -- single color (no background color)
            form.addColorField(line, slots[3],
                function() return widget.logics:get(i).color end,
                function(newValue) widget.logics:get(i).color = newValue end)
        end
        if widget.useState then
            if widget.showTitle then
                line = panel:addLine("", false)
                positionLabel(line, nil, __("title"), grayColor)
                slots = form.getFieldSlots(line, {0, tagButtonText})
                form.addTextField(line, slots[1],
                    function() return widget.logics:get(i).title end,
                    function(newValue) widget.logics:get(i).title = newValue end)
                addTagButton(line, slots[2], i, "appendTitle")
            end
            line = panel:addLine("", i == count and count >= maxConditions)
            positionLabel(line, nil, __("state"), grayColor)
            slots = form.getFieldSlots(line, {0, tagButtonText})
            textField = form.addTextField(line, slots[1],
                function() return widget.logics:get(i).text end,
                function(newValue) widget.logics:get(i).text = newValue end)
            addTagButton(line, slots[2], i, "appendText")
        end
    end
    if grabFocus and textField then
        textField:focus()
    elseif grabFocus and choiceField then
        choiceField:focus()

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
                        message=L.reflow(__("helpMessage"), maxDialogChars),
                        width=dialogWidth,
                        buttons={{label=__("ok"), action=function() return true end}},
                        options=TEXT_LEFT,
                        closeWhenClickOutside=true
                    })
                end
            }
        )
        -- auto positionned Add button
        local addButton = form.addButton(line, nil, {
            text="+",
            press=function() widget.logics:add() model.dirty() fillLogicPanel(panel, widget) end
        })
        if count == 0 and grabFocus then
            addButton:focus()
        end
    end

end

return {
    fillLogicPanel=fillLogicPanel
}
