-- if key ends with ASCII => no accentuated chars (ethos < 1.7 compatibility)
-- the key ending with UT8 has the same purpose for ethos >= 1.7
-- even in UTF8 not all characters are available, please do check your translation with the nightly26
return {
    widgetNameTypeSourceASCII="Farbwert", --ASCII
    widgetNameTypeSourceUTF8="Farbwert",-- subset utf8
    widgetNameTypeSensorASCII="Farbe Telemerie", --ASCII
    widgetNameTypeSensorUTF8="Farbe Telemerie",-- subset utf8
    source="Quelle",
    case="Fall%d",
    confirmTitle="Bestätigen",
    caseDeleteMessage="Delete Fall%d löschen?",
    conditionLabel="Wenn %s",
    help="Hilfe",
    ok="OK",
    yes="Ja",
    no="Nein",
    logicPanel="Zu verwendende Farbe (optional)",
    showTitle="Titel",
    showMinMax="Minimum und Maximum",
    editMenuASCII="bearbeiten %s", --ASCII
    editMenuUTF8="bearbeiten %s",-- subset utf8
    resetMenuASCII="Zurucksetzen %s", --ASCII
    resetMenuUTF8="Zurücksetzen %s",-- subset utf8
    minimumMenuASCII="Minimum : %s%s", --ASCII
    minimumMenuUTF8="Minimum : %s%s",-- subset utf8
    maximumMenuASCII="Maximum : %s%s", --ASCII
    maximumMenuUTF8="Maximum : %s%s",-- subset utf8
    infoPanelTitle="Widget-Informationen",
    infoPanelGitHubRepo="GitHub-Repository",
    infoPanelVersion="Version",
    infoPanelAuthor="Autor",
    title="Titel (in case of a match)",
    showBackgroundColor="Hintergrundfarbe",
    showCustomStates="Benutzerdefinierte Zustände",
    colorHint="Textfarbe/Hintergrundfarbe",
    helpTagsTitle="Fügen Sie ein Tag ein",
    state="Status",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        Das Widget zeigt den Quellwert in der Standarddesignfarbe an. \z
        Sie können bis zu 5 Schwellenwerte hinzufügen, jeder mit einer eigenen Farbe. Die Reihenfolge \z
        ist wichtig, da nur die erste Übereinstimmung berücksichtigt wird. \z
        Der Fall, der der aktuellen Situation entspricht, ist hervorgehoben.\n\n\z
        \z
        Wenn Sie die Hintergrundfarbe aktivieren, können Sie die Textfarbe und die Hintergrundfarbe festlegen.\n\n\z
        \z
        Wenn es sich bei der Quelle um einen Sensor handelt und die Telemetriedaten verloren gehen, \z
        wird die Warnfarbe des Themas ohne Hintergrund verwendet.\n\z
        Wenn das Widget den Fokus hat, wird die Fokusfarbe angewendet.\n\n\z
        \z
        Benutzerdefinierte Zustände überschreiben, sofern festgelegt, den Wert mit einem benutzerdefinierten Text,  \z
        Spezielle Tags sind über die Schaltfläche neben dem Feld „Bundesland“ verfügbar.\n\z
        When state is empty, the default value is shown in the widget.\n\n\z
        \z
        Bei Sensoren können Minimum und Maximum im Widget angezeigt werden, andernfalls \z
        werden diese Werte im Menü des Widgets angezeigt.\n\n\z",
    helpTags="\z
        Sie können spezielle Tags verwenden, um den Quellnamen oder den Quellwert in unterschiedlichen Genauigkeiten einzufügen. \z
        Weitere Tags sind __ für Unterstrich und _b für Zeilenumbruch. Klicken Sie auf eine Schaltfläche, um den Tag einzufügen"
}
