# 1.1.0-rc3

This is a pre-release version, it should be use only by translators and people willing to test and report.

Although I added many features, the UI can stay very minimmalist, as before.

Changed from RC2:

- fix condition choice width on X18RS
- properly escape source:name and source:stringValue when using tags
- added more tags (_u _10v _100v, and multiplier tag _2x or as divider _0.5x)
- fix suffix of analog category
- as I still was not satisfied with the ui for Title tags, I moved then inside each logic case
- due to the change above I hit some storage constraints and I had to refactor the read and write from storage
- the list of tags is published below

The new storage is backward compatible with release 1.0 and all 1.1 pre-release, migration is done automatically.

Changed from RC1:

- german translation added
- the title is only changed in case of a match
- Title moved below the cases due to the preceding change
- help reflow patch to avoid the ethos issue
- for translators, title label is changed and 4th paragraphe of the help message is changed (english inserted in translations)

New features:

- min/max values are shown in the menu only when not displayed in the widget
- possibility to set both text and background color
- possibility to use custom states
- custom states allow the use of special tags to insert source name or source value.
- when using tags, it is possible to use multiple lines
- title might also be modified when using custom states

Example of widget outputs:
![go-crazy-demo](https://github.com/user-attachments/assets/0fb564c0-a947-496a-a3c1-8823d7405dc8)

The doc is coming for custom tags, most useful ones are already in the dialog which popups from the "..." button. Probably an overkill for most users, but here is the list to play with:

| tag   | replacement value                              | Example |
|-------|------------------------------------------------|---------|
| _v    | The value of the source using source precision | 4.15    |
| _0v   | The value of the source as integer             | 4       |
| _1v   | The value of the source with one decimal       | 4.1     |
| _nv   | The value of source with n decimals n <= 9     |         |
| _10v  | The value multiplied by 10 as integer          | 41      |
| _100v | The value multiplied by 100 as integer         | 415     |
| _t    | This is the default value as text with unit    | 4.15V   |
| _u    | The unit of the source as string               | V       |
| _2x   | multiplier using source precision              | 8.30    |
| _0.5x | multiplier using source precision              | 2.07    |
| _n    | name of the source.                            | RxBatt  |
| _b    | new line or line break                         |         |
| __    | you may need it for literal underscore         | _       |

## Download

You can download the zip file in the Assets section below.

## Install

The recommended way to install is to use Ethos Studio. The Ethos version on the radio must be ≥ 1.6.3

![Zight 2026-02-20 at 12 49 03 PM](https://github.com/user-attachments/assets/5aa6464a-381f-47f9-b7d7-0009da9111b5)

If you prefer the manual method, unzip, open and drag the folder named exactly _color-value_ in your radio's script folder.

After installation two new widgets are available: _Color Value_ and _Color Telemetry_, both share the same code but _Color Telemetry_ restrict the Source of the value to be a telemetry sensor.

***
