-- if key ends with ASCII => no accentuated chars (ethos < 1.7 compatibility)
-- the key ending with UT8 has the same purpose for ethos >= 1.7
-- even in UTF8 not all characters are available, please do check your translation with the nightly26
return {
    widgetNameTypeSourceASCII="Barevna hodnota", --ASCII
    widgetNameTypeSourceUTF8="Barevná hodnota",-- subset utf8
    widgetNameTypeSensorASCII="Barevna telemetrie", --ASCII
    widgetNameTypeSensorUTF8="Barevná telemetrie",-- subset utf8
    source="Zdroj",
    case="Podmínka%d",
    confirmTitle="Potvrzení",
    caseDeleteMessage="Smazat podmínku%d ?",
    conditionLabel="Když %s",
    help="Pomoc",
    ok="OK",
    yes="Ano",
    no="Ne",
    logicPanel="Nastavení barev (volitelné)",
    showTitle="Název",
    showMinMax="Minimum a Maximum",
    editMenuASCII="Upravit %s", --ASCII
    editMenuUTF8="Upravit %s",-- subset utf8
    resetMenuASCII="Reset %s", --ASCII
    resetMenuUTF8="Reset %s",-- subset utf8
    minimumMenuASCII="Minimum : %s%s", --ASCII
    minimumMenuUTF8="Minimum : %s%s",-- subset utf8
    maximumMenuASCII="Maximum : %s%s", --ASCII
    maximumMenuUTF8="Maximum : %s%s",-- subset utf8
    infoPanelTitle="Informace o widgetu",
    infoPanelGitHubRepo="GitHub repozitář",
    infoPanelVersion="Verze",
    infoPanelAuthor="Autor",
    title="Název (volitelné)",
    showBackgroundColor="Background Color",
    showCustomStates="Custom States",
    colorHint="Text color / Background Color",
    state="State (volitelné)",
    helpTagsTitle="Insert a tag",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        The widget displays the source value using the default theme color. \z
        You may add up to 5 thresholds, each using their own colors. The order \z
        is important as only the first match is considered. \z
        The case matching the current condition is highlighted.\n\n\z
        \z
        If you enable Background Color, you may set the text color and the background color.\n\n\z
        \z
        If the source is a sensor and the telemetry is lost, \z
        the theme's warning color will be used without background.\n\z
        If the widget has the focus, the focus color is applied.\n\n\z
        \z
        Custom States, when set, override the value with a custom text, \z
        and special tags are available in the button next to the state field. \z
        When state is empty, the default value is shown in the widget.\n\n\z
        \z
        For sensors, Minimum and Maximum can be displayed in the widget, otherwise \z
        those values will be shown in the widget's menu.\n\n\z",
    helpTags="\z
        You may use special tags to insert the source name or the source value in different precisions. \z
        Additional tags are  __  for underscore, and  _b  for line break. Click a button to insert the tag."
}
