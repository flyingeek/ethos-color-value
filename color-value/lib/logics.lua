---@diagnostic disable-next-line: undefined-global
local isTimer = L.isTimer
---@diagnostic disable-next-line: undefined-global
local sourceExists = L.sourceExists
---@diagnostic disable-next-line: undefined-global
local trim = L.trim
---@diagnostic disable-next-line: undefined-global
local formatWithDecimals = L.formatWithDecimals
---@diagnostic disable-next-line: undefined-global
local function getWidgetBgColor() return L.defaultWidgetBgColor end

local defaultThreshold = 0

local OPE_NONE = 0
local OPE_LESS = 5
local OPE_MORE = 10
local OPE_MORE_OR_EQUAL = 15
local OPE_LESS_OR_EQUAL = 20
local OPE_EQUAL = 25
local epsilon = 1e-6

local function encode(s)
    if not s then return "" end
    -- replace any "\x" by \ddd (as \x should not be in user input)
    local encoded = s:gsub("\\(.)", function(x)
        return string.format("\\%03d", string.byte(x))
    end)
    -- replace any "," or "/" by their char as they are separator
    encoded = encoded:gsub("([,/])", function(x)
            return string.format("\\%03d", string.byte(x))
        end)
    return encoded
end
local function decode (s)
    if not s then return "" end
    -- replace any \ddd by char(d)
    local decoded = s:gsub("\\(%d%d%d)", function (d)
        return string.char(d)
    end)
    return decoded
end
local function escape(s)
    -- a safe string to store
    return encode(decode(s))
end

local function escapePattern(pattern)
    local escaped = select(1, string.gsub(pattern, "[^%w]", function(x) return string.format("\\%03d", string.byte(x)) end))
    return escaped
end

local function count_b(str)
    local count = 0
    local prev = 0
    local len = #str
    local byte = string.byte

    for i = 1, len - 1 do
        local c = byte(str, i)
        if c == 95 and prev ~= 95 and byte(str, i + 1) == 98 then
            count = count + 1
        end
        prev = c
    end

    return count
end

local function parseTags(text, source)
    local function replaceTag(s)
        local formatted = s
        if sourceExists(source) then
            formatted = (formatted:gsub("_(%d)v", -- replace _0v _1v ..._9v
                                function(digit)
                                    local n = tonumber(digit) or 0
                                    local format = string.format("%%.%df", n)
                                    return string.format(format, tonumber(source:value()) or 0)
                                end)
                            :gsub("_v", tostring(formatWithDecimals(source:value(), source))) -- replace _v
                            :gsub("_t", escapePattern(source:stringValue())) -- replace _t
                            :gsub("_n", escapePattern(source:name()))  -- replace _n
                            :gsub("_u", escapePattern(source:stringUnit() or ""))  -- replace _u
                            :gsub("_1(0+)v", -- replace _10v _100v ...
                                function(multiplier)
                                    return tostring(math.floor(0.5 + (tonumber(source:value()) or 0) * tonumber("1"..multiplier)))
                                end)
                            :gsub("_([%d.]+)x", -- _%fx multiplier using source:decimals...
                                function(multiplier)
                                    return tostring(formatWithDecimals((tonumber(source:value()) or 0) * (tonumber(multiplier) or 0), source))
                                end)

                        )
        end
        return formatted
    end
    if not text then return {""} end
    if not text:find('_') then return {text} end

    -- replace __ by encoded \095
    local encoded = text:gsub("_(_)", function(x)
            return string.format("\\%03d", string.byte(x))
        end)
    local lines = {}
    local sep = "_b"
    for line in string.gmatch(encoded..sep, "(.-)"..sep) do
        table.insert(lines, decode(replaceTag(line)))
    end
    return lines
end

local LogicCase = {
    threshold=defaultThreshold,
    ope=OPE_LESS,
    text="",
    title=""
}
function LogicCase:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.color = o.color or lcd.themeColor(THEME_WARNING_COLOR)
    o.bgcolor = o.bgcolor or getWidgetBgColor()
    return o
end
function LogicCase:test(value)
    if value then
        if self.ope == OPE_NONE then return false
        elseif self.ope == OPE_LESS then return value < self.threshold
        elseif self.ope == OPE_MORE then return value > self.threshold
        elseif self.ope == OPE_LESS_OR_EQUAL then return (value <= self.threshold or math.abs(value - self.threshold) <= epsilon)
        elseif self.ope == OPE_MORE_OR_EQUAL then return (value >= self.threshold or math.abs(value - self.threshold) <= epsilon)
        elseif self.ope == OPE_EQUAL then return math.abs(value - self.threshold) <= epsilon
        else
            warn("unknown OPE code "..self.ope)
        end
    else
        warn("LogicCase:test Attempt to test a nil value")
    end
    return false
end
function LogicCase:__tostring()
    return string.format("LogicCase: ope=%s, threshold=%s, color=%s bgcolor=%s text=%s title=%s", self.ope, self.threshold, self.color, self.bgcolor, self.text, self.title)
end
function LogicCase:asStorageString()
    return string.format("%s,%s,%s,%s,%s,%s", self.ope, self.threshold, self.color, self.bgcolor, escape(trim(self.text)), escape(trim(self.title)))
end
function LogicCase:loadStorageString(s)
    local t = {}
    for m in string.gmatch(s, "([^,]*)") do
        table.insert(t, m)
    end
    if #t ~= 6 then
        warn("LogicCase:loadString bad format "..s)
    end
    if t[1] ~= nil then self.ope = tonumber(t[1]) end
    if t[2] ~= nil then self.threshold = tonumber(t[2]) end
    if t[3] ~= nil then self.color = tonumber(t[3]) end
    if t[4] ~= nil then self.bgcolor = tonumber(t[4]) end
    if t[5] ~= nil then self.text = decode(t[5]) end
    if t[6] ~= nil then self.title = decode(t[6]) end

    return self
end
function LogicCase:getText(source)
    return parseTags(self.text, source)
end
function LogicCase:getTitle(source)
    return parseTags(self.title, source)
end
function LogicCase:appendText(s)
    if s then
        self.text = self.text .. tostring(s)
    end
end
function LogicCase:appendTitle(s)
    if s then
        self.title = self.title .. tostring(s)
    end
end
local LogicCases = {}

function LogicCases:new (source)
    local o = {logicCases = {}}
    setmetatable(o, self)
    self.__index = self
    if isTimer(source) then
        local timer = model.getTimer(source:member())
        if timer then
            local direction = timer:direction()
            if direction then
                if direction > 0 then
                    local alarm = timer:alarm()
                    if alarm  and alarm > 0 then
                        table.insert(o.logicCases, LogicCase:new({ope=OPE_MORE_OR_EQUAL, threshold=alarm}))
                    end
                else
                    table.insert(o.logicCases, LogicCase:new({ope=OPE_LESS_OR_EQUAL, threshold=0}))
                end
            end
        end
    end
    return o
end

function LogicCases:__tostring()
    local out = "{"
    for k, logicCase in pairs(self.logicCases) do
        out = out .."\n".. tostring(logicCase)
    end
    if #(self.logicCases) > 0 then  out = out .. "\n" end
    out = out .."}"
    return out
end

function LogicCases:add(logicCase)
    local newLogic = logicCase
    if newLogic == nil then -- add a new logic from configure panel
        local count = #(self.logicCases)
        newLogic = LogicCase:new()
        if count >= 1 then
            newLogic.ope = self.logicCases[count].ope
            newLogic.threshold = self.logicCases[count].threshold
        end
    end
    table.insert(self.logicCases, newLogic)
    return newLogic
end
function LogicCases:remove(pos)
    table.remove(self.logicCases, pos)
    return self
end
-- legacy function string too long for storage with text and title include
function LogicCases:asStorageString()
    local out=""
    for i,logicCase in pairs(self.logicCases) do
        local sep = i > 1 and "/" or ""
        out = out .. sep .. logicCase:asStorageString()
    end
    return out
end
---- legacy function used to migrate from v1
function LogicCases:loadStorageString(s)
    for line in string.gmatch(s, "([^/]+)") do
        table.insert(self.logicCases, LogicCase:new():loadStorageString(line))
    end
    return self
end
function LogicCases:get(pos)
    return self.logicCases[pos]
end
function LogicCases:matchIndex(value)
    if not value then return nil end
    local index
    for i, logicCase in pairs(self.logicCases) do
        if logicCase:test(value) then
            index = i
            break
        end
    end
    return index
end
function LogicCases:match(value)
    if not value then return nil end
    local matchingCase
    for i, logicCase in pairs(self.logicCases) do
        if logicCase:test(value) then
            matchingCase = logicCase
            break
        end
    end
    return matchingCase
end

function LogicCases:count()
    return #(self.logicCases)
end


return {
    LogicCase = LogicCase,
    ["OPE_LESS_OR_EQUAL"] = OPE_LESS_OR_EQUAL,
    ["OPE_LESS"] = OPE_LESS,
    ["OPE_MORE"] = OPE_MORE,
    ["OPE_MORE_OR_EQUAL"] = OPE_MORE_OR_EQUAL,
    ["OPE_EQUAL"] = OPE_EQUAL,
    LogicCases = LogicCases,
    count_b = count_b,
}
