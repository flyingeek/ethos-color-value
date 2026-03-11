-- if key ends with ASCII => no accentuated chars (ethos < 1.7 compatibility)
-- the key ending with UT8 has the same purpose for ethos >= 1.7
-- even in UTF8 not all characters are available, please do check your translation with the nightly26
return {
    widgetNameTypeSourceASCII="Valeur en couleur", --ASCII
    widgetNameTypeSourceUTF8="Valeur en couleur", -- subset utf8
    widgetNameTypeSensorASCII="Telemetrie en couleur", --ASCII
    widgetNameTypeSensorUTF8="Télémetrie en couleur", -- subset utf8
    source="Source",
    case="Cas%d",
    confirmTitle="Confirmation",
    caseDeleteMessage="Supprimmer le Cas%d ?",
    conditionLabel="Si %s",
    help="Aide",
    ok="OK",
    yes="Oui",
    no="Non",
    logicPanel="Couleur à utiliser (facultatif)",
    showTitle="Titre",
    showMinMax="Minimum and Maximum",
    editMenuASCII="Editer %s", --ASCII
    editMenuUTF8="Editer %s", -- subset utf8
    resetMenuASCII="Reinitialiser %s", --ASCII
    resetMenuUTF8="Réinitialiser %s", -- subset utf8
    minimumMenuASCII="Minimum : %s%s", --ASCII
    minimumMenuUTF8="Minimum : %s%s", -- subset utf8
    maximumMenuASCII="Maximum : %s%s", --ASCII
    maximumMenuUTF8="Maximum : %s%s", -- subset utf8
    infoPanelTitle="Informations sur le widget",
    infoPanelGitHubRepo="Dépôt GitHub",
    infoPanelVersion="Version",
    infoPanelAuthor="Auteur",
    title="Titre (facultatif)",
    showBackgroundColor="Arrière plan",
    showCustomStates="Etats personnalisés",
    colorHint="Couleur Texte / Arrière plan",
    state="Etat (facultatif)",
    helpTagsTitle="Insérer une balise",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        Le widget affiche la valeur de la source en utilisant la couleur par défaut \z
        du thème. Vous pouvez définir jusqu'à 5 seuils, chacun ayant sa propre couleur. \z
        L'ordre des seuils compte : seul le premier cas valide est appliqué. \z
        La condition valide actuelle est en surbrillance.\n\n\z
        \z
        Si vous activez le mode Arrière plan, vous pourrez définir la couleur du texte et de \z
        l'arrière plan.\n\n\z
        \z
        Si la source est un capteur, en cas de perte de télémétrie, la couleur d'avertissement \z
        du thème sera utilisée sans arrière plan.\n\z
        Si le widget a le focus, la couleur du focus sera appliquée.\n\n\z
        \z
        Etat personnalisés, permet de remplacer la valeur de la source par un état que l'on définit, \z
        si l'état est vide la valeur par défaut est affichée. \z
        Les balises permettent en plus d'insérer des valeurs de la source, \z
        elles sont accessibles via le bouton accolé au champ Etat.\n\n\z
        \z
        Pour les capteurs de télémétrie, les valeurs minimum et maximum peuvent s'afficher dans le widget, \z
        à défaut, vous retrouverez ces valeurs dans le menu du widget\n\n\z",
    helpTags="\z
        Vous pouvez utiliser des balises pour insérer le nom de la source, ou la valeur de la source avec \z
        différentes précisions. Vous pouvez aussi utiliser  __  pour insérer le tiret du bas ou  _b  pour \z
        une nouvelle ligne. Cliquer sur un bouton insère la balise correspondante."
}
