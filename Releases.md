# 1.1.1

**Version 1.1.1 fix a critical error in read from storage, all users should perform the update.**

Although I added many features, the UI can stay very minimmalist, as before.

New features:

- min/max values are shown in the menu only when not displayed in the widget
- possibility to set both text and background color
- possibility to use custom states
- custom states allow the use of special tags to insert source name or source value.
- when using tags, it is possible to use multiple lines

Example of widget outputs:
![go-crazy-demo](https://github.com/user-attachments/assets/0fb564c0-a947-496a-a3c1-8823d7405dc8)

## Documentation

A beautiful [interactive documentation](https://flyingeek.github.io/astro-color-value/) is available, including a widget simulator. You can really try in your browser before installing on your radio. It is also a good reference for all available tags.

## Download

You can download the zip file in the Assets section below.

## Install

The recommended way to install is to use Ethos Studio. The Ethos version on the radio must be ≥ 1.6.3

![Zight 2026-02-20 at 12 49 03 PM](https://github.com/user-attachments/assets/5aa6464a-381f-47f9-b7d7-0009da9111b5)

If you prefer the manual method, unzip, open and drag the folder named exactly _color-value_ in your radio's script folder.

After installation, two new widgets become available: **Color Value** and **Color Telemetry**. They use the same underlying code, but **Color Telemetry** limits the source to a telemetry sensor—so if you’re using telemetry, it’s faster to set up with Color Telemetry.

***
