bits 64
default rel

%include "src/config.inc"
%include "src/data.inc"
%include "src/bss.inc"

section .text
global _start

%include "src/x11.asm"
%include "src/node.asm"
%include "src/layout.asm"
%include "src/focus.asm"
%include "src/tree.asm"
%include "src/keys.asm"
%include "src/spawn.asm"
%include "src/actions.asm"
%include "src/auth.asm"
%include "src/tags.asm"
%include "src/ewmh.asm"
%include "src/reply.asm"
%include "src/float.asm"
%include "src/events.asm"
%include "src/main.asm"
