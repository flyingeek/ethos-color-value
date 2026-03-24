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
    showBackgroundColor="Barva pozadí",
    showCustomStates="Vlastní stavy",
    colorHint="Barva textu / Barva pozadí",
    state="Stav (volitelné)",
    helpTagsTitle="Vložit značku",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        Widget zobrazuje hodnotu zdroje ve výchozí barvě motivu. \z
        Můžete přidat až 5 prahů, každý s vlastní barvou. Pořadí \z
        je důležité, protože se bere v úvahu pouze první shoda. \z
        Podmínka odpovídající aktuálnímu stavu je zvýrazněna.\n\n\z
        \z
        Pokud povolíte Barvu pozadí, můžete nastavit barvu textu i barvu pozadí.\n\n\z
        \z
        Pokud je zdrojem senzor a dojde ke ztrátě telemetrie, \z
        použije se varovná barva motivu bez pozadí.\n\z
        Pokud má widget fokus, použije se barva fokusu.\n\n\z
        \z
        Vlastní stavy po nastavení nahradí hodnotu vlastním textem \z
        a speciální značky jsou dostupné v tlačítku vedle pole stav. \z
        Když je stav prázdný, ve widgetu se zobrazí výchozí hodnota.\n\n\z
        \z
        U senzorů lze ve widgetu zobrazit Minimum a Maximum, jinak \z
        se tyto hodnoty zobrazí v menu widgetu.\n\n\z",
    helpTags="\z
        Můžete použít speciální značky pro vložení názvu zdroje nebo hodnoty zdroje s různou přesností. \z
        Další značky najdete v dokumentaci. Kliknutím na tlačítko značku vložíte."
}
