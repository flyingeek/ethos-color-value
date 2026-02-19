local locales = {}

locales.widgetNameTypeSource = { -- no accentuated characters here for ethos < 1.7 compatibility
    en = "Color Value",
    fr = "Valeur en couleur",
}
locales.widgetNameTypeSensor = { -- no accentuated characters here for ethos < 1.7 compatibility
    en = "Color Telemetry",
    fr = "Telemetrie en couleur",
}
locales.source = {
    en = "Source",
    fr = "Source",
}
locales.case = {
    en = "Case%d",
    fr = "Cas%d",
}
locales.caseDeleteTitle = {
    en = "Confirm",
    fr = "Confirmation",
}
locales.caseDeleteMessage = {
    en = "Delete Case%d ?",
    fr = "Supprimmer le Cas%d ?",
}
locales.conditionLabel = {
    en = "If %s",
    fr = "Si %s",
}
locales.help = {
    en = "Help",
    fr = "Aide",
}
locales.ok = {
    en = "OK",
    fr = "OK",
}
locales.yes = {
    en = "Yes",
    fr = "Oui",
}
locales.no = {
    en = "No",
    fr = "Non",
}
locales.helpMessage = { -- \z must be at the end of each line except the last one. \n is a newline
    en = "\z
        The widget displays the source value using the default theme color. \z
        You may add up to 5 thresholds, each using their own colors. The order \z
        is important as only the first match is considered. \z
        The case matching the current condition is highlighted.\n\z
        If the source is a sensor and the telemetry is lost, \z
        the theme's warning color will be used.",
    fr = "\z
        Le widget affiche la valeur de la source en utilisant la couleur par défaut du thème. \z
        Vous pouvez définir jusqu'à 5 seuils, chacun ayant sa propre couleur. L'ordre des \z
        seuils compte : seul le premier cas valide est appliqué. \z
        La condition valide actuelle est en surbrillance.\n\n\z
        Si la source est un capteur, en cas de perte de télémétrie, la couleur d'avertissement du thème est utilisée.",
}
locales.logicPanel = {
    en = "Color to use (optional)",
    fr = "Couleur à utiliser (optionnel)",
}
locales.showTitle = {
    en = "Title",
    fr = "Titre",
}
locales.showMinMax = {
    en = "Minimum and Maximum",
    fr = "Minimum et Maximum",
}
locales.resetMenu = { -- no accentuated characters here for ethos < 1.7 compatibility
    en = "Reset %s",
    fr = "Reinitialiser %s",
}
locales.minimumMenu = { -- no accentuated characters here for ethos < 1.7 compatibility
    en = "Minimum : %s%s",
    fr = "Minimum : %s%s",
}
locales.maximumMenu = { -- no accentuated characters here for ethos < 1.7 compatibility
    en = "Maximum : %s%s",
    fr = "Maximum : %s%s",
}
locales.infoPanelTitle = {
    en="Widget informations",
    fr="Informations sur le widget"
}
locales.infoPanelWidgetName = {
    en="Widget name",
    fr="Nom du widget"
}
locales.infoPanelVersion = {
    en="Version",
    fr="Version"
}
locales.infoPanelAuthor = {
    en="Author",
    fr="Auteur"
}
local function translate(key, locale)
    local ANSI_BOLD_YELLOW = "\27[1;33m"
    local ANSI_RESET  = "\27[0m"
    local translations = locales[key]
    if locale == nil then locale = system.getLocale() end
    if translations then
        local translation = translations[locale]
        if translation then
            return translation
        else
            translation = translations["en"]
            if translation then
                warn(ANSI_BOLD_YELLOW .. string.format("using fallback translation [en] for key %s (locale: %s)", key, locale) .. ANSI_RESET)
                return translation
            end
        end
    end
    warn(ANSI_BOLD_YELLOW .. string.format("no translation found for key %s (locale: %s)", key, locale) .. ANSI_RESET)
    return key
end

return { translate = translate }
