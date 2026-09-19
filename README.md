# BetterLoot

BetterLoot is a lightweight, standalone World of Warcraft addon that replaces
the default group-loot roll window with clean, compact roll bars inspired by
ElvUI.

Each roll displays the item icon, item level, stack count, bind type, item
name, quality-colored timer, and all available choices—including Need, Greed,
Transmog, Disenchant, and Pass. Multiple rolls stack neatly, while additional
rolls wait in a queue until space becomes available.

BetterLoot has no ElvUI dependency and requires no external libraries.

## Features

- Compact group-loot roll interface
- Support for up to five visible rolls
- Need, Greed, Transmog, Disenchant, and Pass buttons
- Quality-colored countdown bars
- Item tooltips and comparison support
- Movable, account-wide saved position
- Automatic cleanup when rolls expire or are cancelled
- Safe combat handling
- Built-in visual preview

## Commands

- `/betterloot test` — preview the roll window
- `/betterloot unlock` — show the draggable mover
- `/betterloot lock` — lock and save the position
- `/betterloot reset` — restore the default position

## Installation

Install BetterLoot in your World of Warcraft `Interface/AddOns` directory,
enable it from the AddOns menu, and reload the game. Use `/betterloot unlock`
to place the roll window wherever it fits your UI.
