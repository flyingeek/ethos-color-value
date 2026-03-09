-- Build our namespace
local params = {...}
local libVars = params[1]
local name = params[2]
local ns = {}
for k,v in pairs(libVars) do
    ns[k] = v
end

system.compile("i18n/i18n.lua")
local i18n = assert(loadfile("i18n/i18n.luac", "b"))(ns.isUTF8Compatible)
ns.translate = i18n.translate
ns.getLocale = i18n.getLocale
ns.changeLocale = i18n.changeLocale
i18n = nil

local libEnv = {[name] = ns}
setmetatable(libEnv, {__index = _G})

-- adds to our namespace, using a single level structure
local function include(path)
    system.compile(path)
    local compiledPath = path .. 'c'
    for k,v in pairs(assert(loadfile(compiledPath, "b", libEnv))()) do
        if ns[k] then warn(k .. " is not a unique name") end
        ns[k] = v
    end
end

include("lib/utils.lua") -- first due to possible dependancies
include("lib/logics.lua") -- utils dependancy
include("lib/fields.lua") -- utils dependancy
include("lib/panels.lua") -- utils/logics/fields dependancies

libEnv = nil
libVars = nil
return ns
