# 1.1.0-rc2

This is a pre-release version, it should be use only by translators and people willing to test and report.

Although I added many features, the UI can stay very minimmalist, as before.

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
![go crazy example](https://github.com/user-attachments/assets/5aa6464a-381f-47f9-b7d7-0009da9111b5)

## Download

You can download the zip file in the Assets section below.

## Install

The recommended way to install is to use Ethos Studio. The Ethos version on the radio must be ≥ 1.6.3

![Zight 2026-02-20 at 12 49 03 PM](https://github.com/user-attachments/assets/5aa6464a-381f-47f9-b7d7-0009da9111b5)

If you prefer the manual method, unzip, open and drag the folder named exactly _color-value_ in your radio's script folder.

After installation two new widgets are available: _Color Value_ and _Color Telemetry_, both share the same code but _Color Telemetry_ restrict the Source of the value to be a telemetry sensor.

***
