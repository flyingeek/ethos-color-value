# 1.1.2-rc8

This is a pre-release version, if you do not intend to help by reporting bugs, please use the released stable version instead.

## Changes

- Color Telemetry now uses the same input type as Color Value, but it preselects the Telemetry Category. This solve the annoyance of not having the hamburger menu to select an option.
- Logic Case Highlighting is now updated live when source changes. This will require Ethos >= 26.1.0 RC4 or Ethos >= 1.6.7
- compatible with the new installation manifest of Ethos Suite 1.7.2
- compatible with new themes of Ethos 26.1.0 RC2/RC3
- _x tag now accepts negative values
- Logic Case Highlighting uses ACTIVE_COLOR and INACTIVE_COLOR (same colors as Logic Switches)
- removed 2 potential risks of nil value (one in logic tag parser, one in the configure panel)
- optimized the hotpath (wakeup, paint) to reduce at minimum table/string allocations

---

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

After installation, two new widgets become available: **Color Value** and **Color Telemetry**. They use the same underlying code, but **Color Telemetry** is like a shortcut, it preselects the Telemetry category — so if you’re using telemetry, it’s faster to set up with Color Telemetry.

***
