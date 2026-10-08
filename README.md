# rawm

`rawm` is a tiling window manager for X11, written in x86-64 NASM assembly. It communicates with the X server directly through the X11 Unix socket and does not use Xlib.

## Features

- BSP-style tiling with adjustable layout and window swapping
- Nine tags (workspaces)
- Floating dialogs and fullscreen windows
- Focus borders and keyboard-driven window management
- EWMH properties for desktop and window state
- Work-area adjustment for dock struts, including Polybar

## Build

Requires NASM and a Linux x86-64 system with X11.

```sh
sudo make
```

## Run

Run `rawm` from an X11 session without another window manager active. The terminal and launcher commands are set in `src/binds.inc` (`ghostty` and `dmenu_run` by default).

## Configuration

Colors, gaps and other constants are in `src/config.inc`.

All key bindings live in `src/binds.inc`, one per line. Adding a binding never requires touching any other file.

```
bind    <keycode>, <modifiers>, <action>
exec    <keycode>, <modifiers>, "<shell command>"
tagkeys <first keycode>, <switch modifiers>, <move modifiers>
```

Modifiers are `SHIFT`, `CTRL`, `MODK` (Alt) and `SUPER`, combined with `|`, or `0` for a bare key. Keycodes come from `xev` or `xmodmap -pke`.

Actions: `A_CLOSE`, `A_NEXT`, `A_PREV`, `A_SHRINK`, `A_GROW`, `A_FLIP`, `A_BALANCE`, `A_SWAPN`, `A_SWAPP`, `A_FULL`, `A_KILL`, `A_QUIT`.

Examples:

```
exec 36, MODK, "ghostty"
exec 123, 0, "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
bind 24, MODK|SHIFT, A_KILL
```

Commands run through `/bin/sh -c`. After editing, run `make` and restart `rawm`.

## Source layout

- `rawm.asm` - entry file that includes all modules
- `src/config.inc` - constants
- `src/data.inc` - initialized data and strings
- `src/binds.inc` - key bindings (edit this)
- `src/keytab.inc` - binding macros and the key table
- `src/bss.inc` - uninitialized data
- `src/x11.asm` - socket I/O and request helpers
- `src/reply.asm` - reply waiting and property reading
- `src/auth.asm` - Xauthority lookup
- `src/node.asm`, `src/layout.asm`, `src/tree.asm` - BSP tree and layout
- `src/focus.asm` - focus handling
- `src/keys.asm` - key grabbing
- `src/spawn.asm` - process spawning
- `src/actions.asm` - key actions
- `src/tags.asm` - tags (workspaces)
- `src/ewmh.asm` - EWMH properties and fullscreen
- `src/float.asm` - floating windows
- `src/events.asm` - event handling
- `src/main.asm` - startup and error paths
