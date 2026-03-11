-- if key ends with ASCII => no accentuated chars (ethos < 1.7 compatibility)
-- the key ending with UT8 has the same purpose for ethos >= 1.7
-- even in UTF8 not all characters are available, please do check your translation with the nightly26
return {
    widgetNameTypeSourceASCII="Valore Colore", --ASCII
    widgetNameTypeSourceUTF8="Valore Colore",-- subset utf8
    widgetNameTypeSensorASCII="Colore Telemetria", --ASCII
    widgetNameTypeSensorUTF8="Colore Telemetria",-- subset utf8
    source="Sorgente",
    case="Cas%d",
    confirmTitle="Conferma",
    caseDeleteMessage="Cancella Cas%d ?",
    conditionLabel="Se %s",
    help="Aiuto",
    ok="OK",
    yes="Si",
    no="No",
    logicPanel="Colore da usare (opzionale)",
    showTitle="Titolo",
    showMinMax="Minimo e Massimo",
    editMenuASCII="Modifica %s", --ASCII
    editMenuUTF8="Modifica %s",-- subset utf8
    resetMenuASCII="Reset %s", --ASCII
    resetMenuUTF8="Reset %s",-- subset utf8
    minimumMenuASCII="Minimo : %s%s", --ASCII
    minimumMenuUTF8="Minimo : %s%s",-- subset utf8
    maximumMenuASCII="Massimo : %s%s", --ASCII
    maximumMenuUTF8="Massimo : %s%s",-- subset utf8
    infoPanelTitle="Informazioni Widget",
    infoPanelGitHubRepo="GitHub repository",
    infoPanelVersion="Versione",
    infoPanelAuthor="Autore",
    title="Titolo (opzionale)",
    showBackgroundColor="Colore Sfondo",
    showCustomStates="Stati Personalizzati",
    colorHint="Colore Testo / Colore Sfondo",
    helpTagsTitle="Inserisci un tag",
    state="Stato (opzionale)",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        Il widget mostra i valori sorgenti usando il tema colore predefinito. \z
        Si possono aggiungere fino a 5 soglie, ognuna delle quali con colore indipendente. L'ordine \z
        è importante poiche solo il primo riscontro verrà considerato. \z
        Nel caso combaciante verrà evidenziata la condizione .\n\n\z
        \z
        Se abiliti il colore di sfondo, si potrà impostare il colore testo e il colore sfondo.\n\n\z
        \z
        Se la sorgente è un sensore e se viene persa la telemetria, \z
        Il tema di colore Attenzione/Avviso sarà usato senza lo sfondo.\n\z
        Se il widget ha il focus, verrà utilizzato il colore di Focus.\n\n\z
        \z
        Stati personalizzati, quando impostati, sovrascrivono il valore con un testo personalizzato, \z
        sono disponibili tag speciali nel bottone vicino al campo di stato. \z
        Quando lo stato risulta vuoto, il valore di default viene mostrato nel widget.\n\n\z
        \z
        Per i sensori, minimo e massimo possono essere visualizzati nel widget, in alternativa\z
        questi valori saranno mostrati nel menu del widget.\n\n\z",
    helpTags="\z
        Potete usare Tag speciali per inserire un nome sorgente o il valore sorgente con una precisione differente. \z
        Tag addizionali sono  __  per underscore, e  _b  per interruzione di linea. Clicca un bottone per inserire un tag."
}
