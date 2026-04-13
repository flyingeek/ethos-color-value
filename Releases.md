# 1.1.2-rc2

This is a pre-release version, no feature added, this is just about optimizing memory usage even if this is
not a high demanding widget. The hotpath (wakeup, paint) has been rewritten to reduce at minimum table allocations.

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

After installation, two new widgets become available: **Color Value** and **Color Telemetry**. They use the same underlying code, but **Color Telemetry** limits the source to a telemetry sensor—so if you’re using telemetry, it’s faster to set up with Color Telemetry.  However, note that complex telemetry values (those requiring the use of the hamburger in the source menu) are only available in **Color Value**.

***
