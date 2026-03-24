-- if key ends with ASCII => no accentuated chars (ethos < 1.7 compatibility)
-- the key ending with UT8 has the same purpose for ethos >= 1.7
-- even in UTF8 not all characters are available, please do check your translation with the nightly26
return {
    widgetNameTypeSourceASCII="Valor Color", --ASCII
    widgetNameTypeSourceUTF8="Valor Color",-- subset utf8
    widgetNameTypeSensorASCII="Telemetria en color", --ASCII
    widgetNameTypeSensorUTF8="Telemetria en color",-- subset utf8
    source="Fuente",
    case="Caso%d",
    confirmTitle="Confirmar",
    caseDeleteMessage="Borrar Caso%d ?",
    conditionLabel="Si %s",
    help="Ayuda",
    ok="OK",
    yes="Si",
    no="No",
    logicPanel="Color a usar (opcional)",
    showTitle="Titulo",
    showMinMax="Minimo y Maximo",
    editMenuASCII="Editar %s", --ASCII
    editMenuUTF8="Editar %s",-- subset utf8
    resetMenuASCII="Reiniciar %s", --ASCII
    resetMenuUTF8="Reiniciar %s",-- subset utf8
    minimumMenuASCII="Minimo : %s%s", --ASCII
    minimumMenuUTF8="Minimo : %s%s",-- subset utf8
    maximumMenuASCII="Maximo : %s%s", --ASCII
    maximumMenuUTF8="Maximo : %s%s",-- subset utf8
    infoPanelTitle="Informacion del widget",
    infoPanelGitHubRepo="Repositorio GitHub",
    infoPanelVersion="Version",
    infoPanelAuthor="Autor",
    title="Titulo (opcional)",
    showBackgroundColor="Color de fondo",
    showCustomStates="Estados personalizados",
    colorHint="Color de texto / Color de fondo",
    helpTagsTitle="Insertar una etiqueta",
    state="Estado (opcional)",
    -- \z must be at the end of each line except the last one. \n is a newline
    -- put a space before the \z unless there is a \n
    helpMessage="\z
        El widget muestra el valor de la fuente usando el color predeterminado del tema. \z
        Puede agregar hasta 5 umbrales, cada uno con su propio color. El orden \z
        es importante, ya que solo se considera la primera coincidencia. \z
        El caso que coincide con la condicion actual se resalta.\n\n\z
        \z
        Si activa Color de fondo, puede definir el color del texto y el color de fondo.\n\n\z
        \z
        Si la fuente es un sensor y se pierde la telemetria, \z
        se usara el color de advertencia del tema sin fondo.\n\z
        Si el widget tiene el foco, se aplica el color de foco.\n\n\z
        \z
        Estados personalizados, cuando se configuran, reemplazan el valor con un texto personalizado, \z
        y hay etiquetas especiales disponibles en el boton junto al campo de estado. \z
        Cuando el estado esta vacio, se muestra el valor predeterminado en el widget.\n\n\z
        \z
        En sensores, Minimo y Maximo pueden mostrarse en el widget; de lo contrario, \z
        estos valores se mostraran en el menu del widget.\n\n\z",
    helpTags="\z
        Puede usar etiquetas especiales para insertar el nombre de la fuente o el valor de la fuente con distintas precisiones. \z
        Puede encontrar etiquetas adicionales en la documentacion. Haga clic en un boton para insertar la etiqueta."
}
