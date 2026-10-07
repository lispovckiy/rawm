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
nasm -f elf64 rawm.asm -o rawm.o
ld rawm.o -o rawm
```

## Run

Run `rawm` from an X11 session without another window manager active. The terminal and application launcher commands are configured in the source as `ghostty` and `dmenu_run`.

## Configuration

Key bindings, colors, gaps, and launch commands are defined near the beginning of `rawm.asm`.
