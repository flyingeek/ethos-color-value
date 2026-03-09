local locale
local params = {...}
local isUTF8Compatible = params[1]

system.compile("i18n/en.lua")
local i18nMap = {
  en = assert(loadfile("i18n/en.luac", "b"))(),
}

local i18nFiles = system.listFiles("i18n")
local function changeLocale(newLocale)
    if newLocale == locale then return end
    if locale and locale ~= "en" then i18nMap[locale] = nil end
    if newLocale ~= "en" then -- en already loaded
        for _, value in ipairs(i18nFiles) do
            if value == (newLocale .. ".lua") then
                system.compile("i18n/" .. newLocale .. ".lua")
                i18nMap[newLocale] = assert(loadfile("i18n/" .. newLocale .. ".luac", "b"))()
            end
        end
    end
    locale = newLocale
end
changeLocale(system.getLocale())

local function translate(key, paramTable)
    local ANSI_BOLD_YELLOW = "\27[1;33m"
    local ANSI_RESET = "\27[0m"
    local cKey = key
    if isUTF8Compatible and key:sub(-5) == "ASCII" then
        cKey = key:sub(1, -6) .. "UTF8"
    end
    local map = i18nMap[locale] or i18nMap['en']
    local translation = map[cKey]
    if translation then
        return translation
    else
        translation = i18nMap['en'][cKey]
        if translation then
            warn(ANSI_BOLD_YELLOW .. string.format("using fallback translation [en] for key %s (locale: %s)", cKey, locale) .. ANSI_RESET)
            return translation
        end
    end
    warn(ANSI_BOLD_YELLOW..string.format("translate key \"%s\" is missing", cKey)..ANSI_RESET)
    return cKey
end

return { translate=translate, changeLocale=changeLocale, getLocale=function() return locale end }
