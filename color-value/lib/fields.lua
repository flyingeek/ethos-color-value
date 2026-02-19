---@class FormLine
---@class NumberEdit

---@diagnostic disable-next-line: undefined-global
local defaultSourcePrecision = L.defaultSourcePrecision  -- defined in running env

--- addDynamicSourceNumberField
--- adds a number field performing factorization of input/output values
--- performs factorization according to the source parameters (decimals, minimum, maximum, suffix)
---@param line (FormLine): the line where the field should be added
---@param rect (table): the coordinates
---@param min (integer): the min value
---@param max (integer): the max value
---@param getValue (function): the function which will return the current value
---@param setValue (function): the function which will be called on value change
---@returns table
local function addFactoredNumberField(line, rect, min, max, getValue, setValue)
    local function factorInt(x, precision)
        if not x then return x end
        return math.floor(x * (10 ^ precision) + 0.5)
    end
    local function factorFloat(x, precision)
        if not x then return x end
        return math.floor(x + 0.5) / (10 ^ precision)
    end
    local field
    field = form.addNumberField(line, rect, min, max,
            function() return factorInt( getValue(), field and field:decimals() or 0) end,
            function(newValue) return setValue(factorFloat(newValue, field and field:decimals() or 0)) end)

    local updateFromSource = function (source)
        local defaultSuffix = ""
        local defaultMaximum = 1024  -- TODO which value should be here ?
        local defaultMinimum = - defaultMaximum
        if source and source:category() ~= CATEGORY_NONE then
            local category = source:category()
            if category == CATEGORY_TIMER then
                defaultSuffix = "s"
            end
            if category == CATEGORY_ANALOG or category == CATEGORY_CHANNEL then
                defaultSuffix = "%"
            end
            local precision = source.decimals and source:decimals() or defaultSourcePrecision
            field:decimals(precision)
            field:suffix(source:stringUnit() ~="" and (" " .. source:stringUnit()) or defaultSuffix)
            field:minimum(factorInt(source:minimum(), precision))
            field:maximum(factorInt(source:maximum(), precision))
        else
            field:decimals(defaultSourcePrecision)
            field:suffix(defaultSuffix)
            field:minimum(factorInt(defaultMaximum, defaultSourcePrecision))
            field:maximum(factorInt(defaultMinimum, defaultSourcePrecision))
        end
    end

    return {field=field, updateFromSource=updateFromSource}
end

return {
    addFactoredNumberField=addFactoredNumberField
}
