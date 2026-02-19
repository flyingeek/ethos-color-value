---@diagnostic disable-next-line: undefined-global
local isTimer = L.isTimer

local defaultThreshold = 0

local OPE_NONE = 0
local OPE_LESS_OR_EQUAL = 20
local OPE_LESS = 5
local OPE_MORE = 10
local OPE_MORE_OR_EQUAL = 15
local epsilon = 1e-6

local LogicCase = {
    threshold=defaultThreshold,
    ope=OPE_LESS,
    color=lcd.themeColor(THEME_WARNING_COLOR)
}
function LogicCase:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function LogicCase:test(value)
    if value then
        if self.ope == OPE_NONE then return false end
        if self.ope == OPE_LESS then return value < self.threshold end
        if self.ope == OPE_MORE then return value > self.threshold end
        if self.ope == OPE_LESS_OR_EQUAL then return (value <= self.threshold or math.abs(value - self.threshold) <= epsilon) end
        if self.ope == OPE_MORE_OR_EQUAL then return (value >= self.threshold or math.abs(value - self.threshold) <= epsilon) end
        warn("unknown OPE code "..self.ope)
    else
        warn("LogicCase:test Attempt to test a nil value")
    end
    return false
end
function LogicCase:__tostring()
    return string.format("LogicCase: ope=%s, threshold=%s, color=%s", self.ope, self.threshold, self.color)
end
function LogicCase:asStorageString()
    return string.format("%s,%s,%s", self.ope, self.threshold, self.color)
end
function LogicCase:loadStorageString(s)
    local t = {}
    for m in string.gmatch(s, "([^,]+)") do
        table.insert(t, m)
    end
    if #t ~= 3 then
        warn("LogicCase:loadString bad format "..s)
    else
        self.ope = tonumber(t[1])
        self.threshold = tonumber(t[2])
        self.color = tonumber(t[3])
    end
    return self
end

local function newLogics(source)
    local logics = {}
    if isTimer(source) then
        local timer = model.getTimer(source:member())
        if timer then
            local direction = timer:direction()
            if direction then
                if direction > 0 then
                    local alarm = timer:alarm()
                    if alarm  and alarm > 0 then
                        table.insert(logics, LogicCase:new({ope=OPE_MORE_OR_EQUAL, threshold=alarm}))
                    end
                else
                    table.insert(logics, LogicCase:new({ope=OPE_LESS_OR_EQUAL, threshold=0}))
                end
            end
        end
    end
    return logics
end

return {
    LogicCase = LogicCase,
    ["OPE_LESS_OR_EQUAL"] = OPE_LESS_OR_EQUAL,
    ["OPE_LESS"] = OPE_LESS,
    ["OPE_MORE"] = OPE_MORE,
    ["OPE_MORE_OR_EQUAL"] = OPE_MORE_OR_EQUAL,
    newLogics=newLogics
}
