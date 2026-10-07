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

Run `rawm` from an X11 session without another window manager active. The terminal and application launcher commands are configured in the source as `ghostty` and `dmenu_run`.

## Configuration

Colors, gaps and other constants are in `src/config.inc`. Key bindings and launch commands are in `src/data.inc`.

## Source layout

- `rawm.asm` - entry file that includes all modules
- `src/config.inc` - constants
- `src/data.inc` - initialized data, key table, strings
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
