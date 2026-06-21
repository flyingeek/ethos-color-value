---@meta COLOR_VALUE

---@class L
---@field defaultSourcePrecision integer
---@field runningInSimulator boolean
---@field infoIcon boolean
---@field deleteIcon boolean
---@field isUTF8Compatible boolean
---@field needsDialogReflow boolean
---@field MAX_CONDITIONS integer
---@field secondaryColor integer
---@field defaultColor integer
---@field defaultWidgetBgColor integer,
---@field focusBgColor integer,
---@field ANSI_RED string
---@field ANSI_GREEN string
---@field ANSI_YELLOW string
---@field log log
---@field prettyTable prettyTable
---@field OPE_LESS_OR_EQUAL integer
---@field OPE_MORE_OR_EQUAL integer
---@field OPE_LESS integer
---@field OPE_MORE integer
---@field OPE_EQUAL integer
---@field LogicCase LogicCase
---@field LogicCases LogicCases
local L = {}

--- translate a string, returns the key if no translation is found, logs a warning
---@param key string
---@return string
function L.translate(key) end

---@param newLocale locale
function L.changeLocale(newLocale) end

---@return locale
function L.getLocale() end

---@param source (Source|nil): the source to check
---@return boolean
function L.isSensor(source) end

---@param source (Source|nil): the source to check
---@return boolean
function L.isTimer(source) end

---@param source (Source): the source to check
---@return boolean
function L.sourceExists(source) end

---replace all UTF8 characters with altChar
---@param text string
---@param altChar string|nil default " "
---@return string
function L.replaceUTF8(text, altChar) end

--- set the font to fit text into a box (fit maxWidth and fit maxHeight)
---@param strOrTable table|string
---@param fontIndexList table
---@param maxWidth integer|nil
---@param maxHeight integer|nil
---@param altChar string|nil
---@param startIndex integer|nil
---@param endIndex integer|nil
---@return integer boxWidth, integer boxHeight, integer lineHeight, integer bestFontIndex, boolean overflow
function L.bestFit(strOrTable, fontIndexList, maxWidth, maxHeight, altChar, startIndex, endIndex) end

--- set the font for the best overlap (fit maxWidth OR fit maxHeight)
---@param str string
---@param fontIndexList table
---@param maxWidth integer
---@param maxHeight integer
---@param altChar string|nil
---@param startIndex integer|nil
---@param endIndex integer|nil
---@return integer boxWidth, integer boxHeight, integer bestFontIndex, boolean overflow
function L.bestOverlap(str, fontIndexList, maxWidth, maxHeight, altChar, startIndex, endIndex) end

--- format a number using source:decimals
---@param value string|number|nil default 0
---@param source (Source)
---@return string
function L.formatWithDecimals(value, source) end

--- wraps in a confirm dialog, accept fn of a text button or options of a button
---@param fn (function)
---@param message string|nil
---@param width integer|nil
---@return function returning a Dialog
function L.confirm(fn, message, width) end

---@param s string|nil
---@return string
function L.trim(s) end

--- reflow dialog for Ethos <= 1.6.5 (L.needsDialogReflow)
---@param str string
---@param limit integer|nil default 72
---@param indent string|nil default ""
---@param indent1 string|nil default indent
---@return string
function L.reflow(str, limit, indent, indent1) end

---add a NumberField with automatic factorization according to source
---@param line FormLine
---@param rect Rect|nil
---@param min integer
---@param max integer
---@param getValue fun(): integer
---@param setValue fun(value: integer)
---@return { field: NumberEditLib, updateFromSource: fun(source: Source) }
function L.addFactoredNumberField(line, rect, min, max, getValue, setValue) end

--- fill the logic panel
---@param panel ExpansionPanel|nil
---@param widget Widget|nil
---@param grabFocus boolean|nil
function L.fillLogicPanel(panel, widget, grabFocus) end

--- highlight the active case in the logic panel
---@param widgetInstance Widget|nil
function L.logicPanelHighlighter(widgetInstance) end

---Loop through each line of a text and parse tags, calling onLine for each line
---@param text string|nil
---@param source Source|nil
---@param onLine nil|fun(line: string):(nil|false)
function L.parseTagsEach(text, source, onLine) end
