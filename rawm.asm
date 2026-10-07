bits 64
default rel

SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_SOCKET  equ 41
SYS_CONNECT equ 42
SYS_EXIT    equ 60
SYS_OPEN    equ 2
DISPCH      equ '0'

MAXN        equ 128
BW          equ 2
GAP         equ 4
OUTER_GAP   equ 12

COL_FOC     equ 0x88c0d0
COL_UNFOC   equ 0x3b4252
ENTER_MASK  equ 0x10
MODK        equ 0x08
RESIZE_STEP equ 50
SYS_FORK    equ 57
SYS_EXECVE  equ 59
SYS_SIGACT  equ 13

A_TERM      equ 0
A_CLOSE     equ 1
A_NEXT      equ 2
A_PREV      equ 3
A_SHRINK    equ 4
A_GROW      equ 5
A_FLIP      equ 6
A_QUIT      equ 7
A_DMENU     equ 8
A_BALANCE   equ 9
A_SWAPN     equ 10
A_SWAPP     equ 11
A_FULL      equ 12
A_KILL      equ 13

NTAGS       equ 9
FLN         equ 16

FL_FS       equ 0x100

AT_PROTO    equ 0
AT_DELETE   equ 1
AT_UTF8     equ 2
AT_SUPPORTED equ 3
AT_CHECK    equ 4
AT_NDESK    equ 5
AT_CDESK    equ 6
AT_ACTIVE   equ 7
AT_CLIENTS  equ 8
AT_STATE    equ 9
AT_FULL     equ 10
AT_WTYPE    equ 11
AT_DIALOG   equ 12
AT_SPLASH   equ 13
AT_UTIL     equ 14
AT_WMNAME   equ 15
AT_DOCK     equ 16
AT_STRUT    equ 17
AT_STRUT_OLD equ 18

BUFSZ       equ 16384

N_WIN       equ 0
N_PAR       equ 8
N_L         equ 12
N_R         equ 16
N_USED      equ 20
N_DIR       equ 24
N_RAT       equ 28
N_FLG       equ 4

section .data

root_node   dd -1
focus       dd -1
cur         dd 0
ntags       dd NTAGS
roots       dd -1, -1, -1, -1, -1, -1, -1, -1, -1
foci        dd -1, -1, -1, -1, -1, -1, -1, -1, -1

sockaddr:
    dw 1
    db "/tmp/.X11-unix/X", DISPCH, 0
SOCKADDR_LEN equ $ - sockaddr

keytab:
    db 36, 0, A_TERM
    db 24, 0, A_CLOSE
    db 44, 0, A_NEXT
    db 45, 0, A_PREV
    db 43, 0, A_SHRINK
    db 46, 0, A_GROW
    db 65, 0, A_FLIP
    db 40, 0, A_DMENU
    db 21, 0, A_BALANCE
    db 44, 1, A_SWAPN
    db 45, 1, A_SWAPP
    db 26, 1, A_QUIT
    db 24, 1, A_KILL
    db 41, 0, A_FULL
    db 10, 0, 16+0
    db 11, 0, 16+1
    db 12, 0, 16+2
    db 13, 0, 16+3
    db 14, 0, 16+4
    db 15, 0, 16+5
    db 16, 0, 16+6
    db 17, 0, 16+7
    db 18, 0, 16+8
    db 10, 1, 32+0
    db 11, 1, 32+1
    db 12, 1, 32+2
    db 13, 1, 32+3
    db 14, 1, 32+4
    db 15, 1, 32+5
    db 16, 1, 32+6
    db 17, 1, 32+7
    db 18, 1, 32+8
KEYS_N equ ($ - keytab) / 3

lockvars:   dw 0, 0x02, 0x10, 0x12

cmd_term    db "ghostty", 0
cmd_menu    db "dmenu_run", 0
sh_path     db "/bin/sh", 0
sh_name     db "sh", 0
sh_c        db "-c", 0
disp_env    db "DISPLAY=:", DISPCH, 0
gdk_env     db "GDK_BACKEND=x11", 0
sig_ign     dq 1, 0, 0, 0
sig_dfl     dq 0, 0, 0, 0

env_xauth   db "XAUTHORITY="
env_home    db "HOME="
xauth_sfx   db "/.Xauthority", 0
mit_name    db "MIT-MAGIC-COOKIE-1"
wm_name     db "rawm"
WM_NAME_LEN         equ $ - wm_name

atom_names:
    db "WM_PROTOCOLS", 0
    db "WM_DELETE_WINDOW", 0
    db "UTF8_STRING", 0
    db "_NET_SUPPORTED", 0
    db "_NET_SUPPORTING_WM_CHECK", 0
    db "_NET_NUMBER_OF_DESKTOPS", 0
    db "_NET_CURRENT_DESKTOP", 0
    db "_NET_ACTIVE_WINDOW", 0
    db "_NET_CLIENT_LIST", 0
    db "_NET_WM_STATE", 0
    db "_NET_WM_STATE_FULLSCREEN", 0
    db "_NET_WM_WINDOW_TYPE", 0
    db "_NET_WM_WINDOW_TYPE_DIALOG", 0
    db "_NET_WM_WINDOW_TYPE_SPLASH", 0
    db "_NET_WM_WINDOW_TYPE_UTILITY", 0
    db "_NET_WM_NAME", 0
    db "_NET_WM_WINDOW_TYPE_DOCK", 0
    db "_NET_WM_STRUT_PARTIAL", 0
    db "_NET_WM_STRUT", 0
    db 0

msg_wm      db "ok: I am the window manager now (Ctrl+C to quit)", 10
MSG_WM_LEN  equ $ - msg_wm
msg_other   db "another window manager is already running on this display", 10
MSG_OTHER_LEN equ $ - msg_other
msg_refused db "server refused: "
MSG_REFUSED_LEN equ $ - msg_refused
msg_nl      db 10
msg_grab    db "warning: GrabKey failed (BadAccess): some Alt+key combo is already grabbed by another program", 10
MSG_GRAB_LEN equ $ - msg_grab
err_sock    db "socket() failed", 10
ERR_SOCK_LEN equ $ - err_sock
err_conn    db "cannot connect to X socket (X not running? other display number?)", 10
ERR_CONN_LEN equ $ - err_conn
err_big     db "X handshake reply too big for buffer", 10
ERR_BIG_LEN equ $ - err_big
err_read    db "connection closed while reading", 10
ERR_READ_LEN equ $ - err_read

section .bss
fd          resq 1
root        resd 1
scrw        resd 1
scrh        resd 1
req         resb 64
ev          resb 32
nodes       resb MAXN*32
hs_buf      resb 48
path_buf    resb 256
grab_warned resb 1
quiet       resb 1
seq         resw 1
rid_base    resd 1
wmcheck     resd 1
actwin      resd 1
fwin        resd 1
bar_top     resd 1
bar_win     resd 1
evq_h       resd 1
evq_n       resd 1
atoms       resd 19
flt         resb FLN*16
rbuf        resb 32
xbuf        resb 256
evq         resb 8*32
init_sp     resq 1
envp_buf    resq 128
argv_buf    resq 4
buf         resb BUFSZ

section .text
global _start

read_exact:
    push rbx
    push r12
    mov rbx, rsi
    mov r12, rdx
.again:
    test r12, r12
    jz .ok
    mov rsi, rbx
    mov rdx, r12
    mov eax, SYS_READ
    syscall
    test rax, rax
    jle .err
    add rbx, rax
    sub r12, rax
    jmp .again
.ok:
    xor eax, eax
    jmp .out
.err:
    mov rax, -1
.out:
    pop r12
    pop rbx
    ret

write_out:
    mov edi, 1
    mov eax, SYS_WRITE
    syscall
    ret

send:
    inc word [seq]
    mov rdi, [fd]
    mov eax, SYS_WRITE
    syscall
    ret

map_window:
    lea rsi, [req]
    mov byte [rsi], 8
    mov byte [rsi+1], 0
    mov word [rsi+2], 2
    mov [rsi+4], edi
    mov edx, 8
    jmp send

send_border:
    lea rdx, [req]
    mov byte [rdx], 2
    mov byte [rdx+1], 0
    mov word [rdx+2], 4
    mov [rdx+4], edi
    mov dword [rdx+8], 0x8
    mov [rdx+12], esi
    mov rsi, rdx
    mov edx, 16
    jmp send

send_focus:
    lea rsi, [req]
    mov byte [rsi], 42
    mov byte [rsi+1], 1
    mov word [rsi+2], 3
    mov [rsi+4], edi
    mov dword [rsi+8], 0
    mov edx, 12
    jmp send

alloc_node:
    lea rdx, [nodes]
    xor eax, eax
.l: cmp eax, MAXN
    jge .none
    mov ecx, eax
    shl ecx, 5
    cmp dword [rdx+rcx+N_USED], 0
    je .found
    inc eax
    jmp .l
.found:
    mov dword [rdx+rcx+N_RAT], 500
    mov dword [rdx+rcx+N_USED], 1
    mov qword [rdx+rcx+N_WIN], 0
    mov dword [rdx+rcx+N_PAR], -1
    mov dword [rdx+rcx+N_L], -1
    mov dword [rdx+rcx+N_R], -1
    mov dword [rdx+rcx+N_DIR], 0
    ret
.none:
    mov eax, -1
    ret

find_win:
    lea rdx, [nodes]
    xor eax, eax
.l: cmp eax, MAXN
    jge .none
    mov ecx, eax
    shl ecx, 5
    cmp dword [rdx+rcx+N_USED], 0
    je .n
    cmp dword [rdx+rcx+N_WIN], edi
    je .ret
.n: inc eax
    jmp .l
.none:
    mov eax, -1
.ret:
    ret

split_sz:
    mov eax, edi
    imul eax, esi
    xor edx, edx
    mov ecx, 1000
    div ecx
    ret

layout:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov ebx, edi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx
    mov r15d, r8d
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    cmp dword [rdx+rax+N_WIN], 0
    je .internal

    mov ecx, [rdx+rax+N_WIN]
    mov r9d, [rdx+rax+N_FLG]
    lea rdi, [req]
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov word [rdi+2], 8
    mov [rdi+4], ecx
    mov word [rdi+10], 0
    test r9d, FL_FS
    jnz .fullscr
    mov word [rdi+8], 0x1f
    lea eax, [r12+GAP]
    mov [rdi+12], eax
    lea eax, [r13+GAP]
    mov [rdi+16], eax
    mov edx, 1
    lea eax, [r14-(2*GAP+2*BW)]
    cmp eax, 1
    cmovl eax, edx
    mov [rdi+20], eax
    lea eax, [r15-(2*GAP+2*BW)]
    cmp eax, 1
    cmovl eax, edx
    mov [rdi+24], eax
    mov dword [rdi+28], BW
    mov rsi, rdi
    mov edx, 32
    call send
    jmp .out
.fullscr:
    mov word [rdi+2], 9
    mov word [rdi+8], 0x5f
    mov dword [rdi+12], 0
    mov dword [rdi+16], 0
    mov eax, [scrw]
    mov [rdi+20], eax
    mov eax, [scrh]
    mov [rdi+24], eax
    mov dword [rdi+28], 0
    mov dword [rdi+32], 0
    mov rsi, rdi
    mov edx, 36
    call send
    jmp .out

.internal:
    cmp dword [rdx+rax+N_DIR], 0
    jne .horiz

    mov edi, r14d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov ecx, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    mov edx, r13d
    mov r8d, r15d
    call layout

    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, r14d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov ecx, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    lea esi, [r12+rcx]
    neg ecx
    add ecx, r14d
    mov edx, r13d
    mov r8d, r15d
    call layout
    jmp .out

.horiz:

    mov edi, r15d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov r8d, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r14d
    call layout

    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, r15d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov r8d, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    lea edx, [r13+r8]
    neg r8d
    add r8d, r15d
    mov esi, r12d
    mov ecx, r14d
    call layout
.out:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

relayout:
    cmp byte [quiet], 0
    jne .r
    mov edi, [root_node]
    cmp edi, -1
    je .r
    mov esi, OUTER_GAP
    mov edx, OUTER_GAP
    add edx, [bar_top]
    mov ecx, [scrw]
    sub ecx, 2*OUTER_GAP
    mov r8d, [scrh]
    sub r8d, 2*OUTER_GAP
    sub r8d, [bar_top]
    jmp layout
.r: ret

set_focus:
    push rbx
    push r12
    mov ebx, edi
    cmp byte [quiet], 0
    jne .qset
    mov edi, [fwin]
    test edi, edi
    jz .nofw
    mov esi, COL_UNFOC
    call send_border
    mov dword [fwin], 0
.nofw:
    mov eax, [focus]
    cmp eax, -1
    je .nold
    lea rdx, [nodes]
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nold
    mov esi, COL_UNFOC
    call send_border
.nold:
    mov [focus], ebx
    cmp ebx, -1
    je .eact
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .eact
    mov r12d, edi
    mov esi, COL_FOC
    call send_border
    mov edi, r12d
    call send_focus
.eact:
    call ewmh_active
    jmp .out
.qset:
    mov [focus], ebx
.out:
    pop r12
    pop rbx
    ret

add_window:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov eax, [root_node]
    cmp eax, -1
    jne .split
    call alloc_node
    cmp eax, -1
    je .done
    mov [root_node], eax
    mov ebx, eax
    jmp .setwin
.split:
    mov ebx, [focus]
    cmp ebx, -1
    je .done
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    test dword [rdx+rax+N_FLG], FL_FS
    jz .nofs
    mov edi, ebx
    xor esi, esi
    call set_fs
.nofs:
    xor r13d, r13d
    mov eax, ebx
    lea rdx, [nodes]
.d: mov ecx, eax
    shl ecx, 5
    mov eax, [rdx+rcx+N_PAR]
    cmp eax, -1
    je .dd
    inc r13d
    jmp .d
.dd:
    call alloc_node
    cmp eax, -1
    je .done
    mov r14d, eax
    call alloc_node
    cmp eax, -1
    jne .ok2
    lea rdx, [nodes]
    mov ecx, r14d
    shl ecx, 5
    mov dword [rdx+rcx+N_USED], 0
    jmp .done
.ok2:
    mov r15d, eax
    lea rdx, [nodes]
    mov esi, ebx
    shl esi, 5
    mov ecx, r14d
    shl ecx, 5
    mov eax, r15d
    shl eax, 5
    mov r8, [rdx+rsi+N_WIN]
    mov [rdx+rcx+N_WIN], r8
    mov [rdx+rcx+N_PAR], ebx
    mov [rdx+rax+N_PAR], ebx
    mov qword [rdx+rsi+N_WIN], 0
    mov [rdx+rsi+N_L], r14d
    mov [rdx+rsi+N_R], r15d
    and r13d, 1
    mov [rdx+rsi+N_DIR], r13d
    mov dword [rdx+rsi+N_RAT], 500
    mov ebx, r15d
.setwin:
    lea rdx, [nodes]
    mov ecx, ebx
    shl ecx, 5
    mov [rdx+rcx+N_WIN], r12d

    lea rdi, [req]
    mov byte [rdi], 2
    mov byte [rdi+1], 0
    mov word [rdi+2], 5
    mov [rdi+4], r12d
    mov dword [rdi+8], 0x808
    mov dword [rdi+12], COL_UNFOC
    mov dword [rdi+16], ENTER_MASK
    mov rsi, rdi
    mov edx, 20
    call send
    cmp byte [quiet], 0
    je .normal
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    inc byte [rdx+rax+N_FLG]
    mov edi, r12d
    call unmap_window
    mov edi, ebx
    call set_focus
    jmp .done
.normal:
    mov edi, r12d
    call map_window
    call relayout
    mov edi, ebx
    call set_focus
    call ewmh_clients
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

remove_leaf:
    push rbx
    push r12
    push r13
    mov ebx, edi
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov r12d, [rdx+rax+N_PAR]
    mov dword [rdx+rax+N_USED], 0
    mov qword [rdx+rax+N_WIN], 0
    cmp r12d, -1
    jne .haspar
    mov dword [root_node], -1
    mov dword [focus], -1
    jmp .out
.haspar:
    mov esi, r12d
    shl esi, 5
    mov ecx, [rdx+rsi+N_L]
    cmp ecx, ebx
    jne .gotS
    mov ecx, [rdx+rsi+N_R]
.gotS:
    mov r13d, ecx
    mov edi, ecx
    shl edi, 5
    mov r8, [rdx+rdi+N_WIN]
    mov [rdx+rsi+N_WIN], r8
    mov r9d, [rdx+rdi+N_L]
    mov [rdx+rsi+N_L], r9d
    mov r10d, [rdx+rdi+N_R]
    mov [rdx+rsi+N_R], r10d
    mov r11d, [rdx+rdi+N_DIR]
    mov [rdx+rsi+N_DIR], r11d
    mov eax, [rdx+rdi+N_RAT]
    mov [rdx+rsi+N_RAT], eax
    mov dword [rdx+rdi+N_USED], 0
    mov qword [rdx+rdi+N_WIN], 0
    cmp r9d, -1
    je .chk
    mov eax, r9d
    shl eax, 5
    mov [rdx+rax+N_PAR], r12d
    mov eax, r10d
    shl eax, 5
    mov [rdx+rax+N_PAR], r12d
.chk:
    mov r8d, [focus]
    cmp r8d, ebx
    je .refocus
    cmp r8d, r13d
    jne .out
.refocus:
    mov eax, r12d
.desc:
    mov ecx, eax
    shl ecx, 5
    mov r8d, [rdx+rcx+N_L]
    cmp r8d, -1
    je .got
    mov eax, r8d
    jmp .desc
.got:
    mov edi, eax
    call set_focus
.out:
    call relayout
    pop r13
    pop r12
    pop rbx
    ret

grab_keys:
    push rbx
    push r12
    push r13
    push r14
    lea rbx, [keytab]
    mov r12d, KEYS_N
.key:
    movzx r13d, byte [rbx+1]
    add r13d, MODK
    xor r14d, r14d
.var:
    lea rdx, [lockvars]
    movzx eax, word [rdx+r14*2]
    or eax, r13d
    movzx ecx, byte [rbx]
    shl ecx, 16
    or eax, ecx
    or eax, 1 << 24
    lea rdi, [req]
    mov byte [rdi], 33
    mov byte [rdi+1], 1
    mov word [rdi+2], 4
    mov ecx, [root]
    mov [rdi+4], ecx
    mov [rdi+8], eax
    mov dword [rdi+12], 1
    mov rsi, rdi
    mov edx, 16
    call send
    inc r14d
    cmp r14d, 4
    jb .var
    add rbx, 3
    dec r12d
    jnz .key
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

build_env:
    lea rdx, [envp_buf]
    lea rax, [disp_env]
    mov [rdx], rax
    lea rax, [gdk_env]
    mov [rdx+8], rax
    mov rcx, [init_sp]
    mov rax, [rcx]
    lea rcx, [rcx+rax*8+16]
    mov esi, 2
.c: mov rax, [rcx]
    test rax, rax
    jz .e
    cmp esi, 126
    jae .e
    mov [rdx+rsi*8], rax
    inc esi
    add rcx, 8
    jmp .c
.e: mov qword [rdx+rsi*8], 0
    ret

spawn:
    push rdi
    mov eax, SYS_FORK
    syscall
    pop rdi
    test rax, rax
    jnz .parent

    push rdi
    mov rdi, [fd]
    mov eax, 3
    syscall
    mov edi, 17
    lea rsi, [sig_dfl]
    xor edx, edx
    mov r10d, 8
    mov eax, SYS_SIGACT
    syscall
    pop rcx
    lea rax, [argv_buf]
    lea rdx, [sh_name]
    mov [rax], rdx
    lea rdx, [sh_c]
    mov [rax+8], rdx
    mov [rax+16], rcx
    mov qword [rax+24], 0
    lea rdi, [sh_path]
    mov rsi, rax
    lea rdx, [envp_buf]
    mov eax, SYS_EXECVE
    syscall
    mov edi, 1
    mov eax, SYS_EXIT
    syscall
.parent:
    ret

target_window:
    mov eax, [fwin]
    test eax, eax
    jnz .r
    mov eax, [focus]
    cmp eax, -1
    je .none
    lea rdx, [nodes]
    shl eax, 5
    mov eax, [rdx+rax+N_WIN]
    ret
.none:
    xor eax, eax
.r: ret

kill_focused:
    call target_window
    test eax, eax
    jz .r
    lea rsi, [req]
    mov byte [rsi], 113
    mov byte [rsi+1], 0
    mov word [rsi+2], 2
    mov [rsi+4], eax
    mov edx, 8
    jmp send
.r: ret

close_focused:
    call target_window
    test eax, eax
    jz .r
    mov r8d, eax
    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 25
    mov byte [rdi+1], 0
    mov word [rdi+2], 11
    mov [rdi+4], r8d
    mov dword [rdi+8], 0
    mov byte [rdi+12], 33
    mov byte [rdi+13], 32
    mov [rdi+16], r8d
    mov eax, [atoms+AT_PROTO*4]
    mov [rdi+20], eax
    mov eax, [atoms+AT_DELETE*4]
    mov [rdi+24], eax
    mov rsi, rdi
    mov edx, 44
    jmp send
.r: ret

next_leaf:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov ebx, [focus]
    cmp ebx, -1
    je .none
    mov r13d, MAXN
.n: add ebx, r12d
    and ebx, MAXN-1
    lea rdx, [nodes]
    mov esi, ebx
    shl esi, 5
    cmp dword [rdx+rsi+N_USED], 0
    je .skip
    cmp dword [rdx+rsi+N_WIN], 0
    je .skip
    mov edi, ebx
    call node_tag
    cmp eax, [cur]
    jne .skip
    mov eax, ebx
    jmp .o
.skip:
    dec r13d
    jnz .n
.none:
    mov eax, -1
.o: pop r13
    pop r12
    pop rbx
    ret

cycle_focus:
    call next_leaf
    cmp eax, -1
    je .r
    mov edi, eax
    jmp set_focus
.r: ret

swap_focused:
    push rbx
    mov ebx, [focus]
    cmp ebx, -1
    je .r
    call next_leaf
    cmp eax, -1
    je .r
    cmp eax, ebx
    je .r
    lea rdx, [nodes]
    mov ecx, ebx
    shl ecx, 5
    mov esi, eax
    shl esi, 5
    mov r8, [rdx+rcx+N_WIN]
    mov r9, [rdx+rsi+N_WIN]
    mov [rdx+rcx+N_WIN], r9
    mov [rdx+rsi+N_WIN], r8
    mov ebx, eax
    call relayout
    mov edi, ebx
    call set_focus
.r: pop rbx
    ret

balance:
    lea rdx, [nodes]
    mov ecx, MAXN
.l: mov dword [rdx+N_RAT], 500
    add rdx, 32
    dec ecx
    jnz .l
    jmp relayout

resize_focused:
    mov eax, [focus]
    cmp eax, -1
    je .r
    lea rdx, [nodes]
    mov esi, eax
    shl esi, 5
    mov ecx, [rdx+rsi+N_PAR]
    cmp ecx, -1
    je .r
    shl ecx, 5
    cmp [rdx+rcx+N_L], eax
    je .left
    neg edi
.left:
    mov eax, [rdx+rcx+N_RAT]
    add eax, edi
    cmp eax, 100
    jge .a
    mov eax, 100
.a: cmp eax, 900
    jle .b
    mov eax, 900
.b: mov [rdx+rcx+N_RAT], eax
    jmp relayout
.r: ret

flip_parent:
    mov eax, [focus]
    cmp eax, -1
    je .r
    lea rdx, [nodes]
    shl eax, 5
    mov ecx, [rdx+rax+N_PAR]
    cmp ecx, -1
    je .r
    shl ecx, 5
    xor dword [rdx+rcx+N_DIR], 1
    jmp relayout
.r: ret

find_env:
    mov rcx, [init_sp]
    mov rax, [rcx]
    lea rcx, [rcx+rax*8+16]
.e: mov rdx, [rcx]
    test rdx, rdx
    jz .no
    xor eax, eax
.c: cmp eax, esi
    je .yes
    mov r9b, [rdx+rax]
    cmp r9b, [rdi+rax]
    jne .nx
    inc eax
    jmp .c
.yes:
    lea rax, [rdx+rsi]
    ret
.nx:
    add rcx, 8
    jmp .e
.no:
    xor eax, eax
    ret

load_auth:
    push rbx
    push r12
    push r13
    lea rdi, [env_xauth]
    mov esi, 11
    call find_env
    test rax, rax
    jnz .have
    lea rdi, [env_home]
    mov esi, 5
    call find_env
    test rax, rax
    jz .none
    mov rsi, rax
    lea rdi, [path_buf]
    mov ecx, 200
.h: mov dl, [rsi]
    test dl, dl
    jz .hd
    mov [rdi], dl
    inc rsi
    inc rdi
    dec ecx
    jnz .h
.hd:
    lea rsi, [xauth_sfx]
.s: mov dl, [rsi]
    mov [rdi], dl
    inc rsi
    inc rdi
    test dl, dl
    jnz .s
    lea rax, [path_buf]
.have:
    mov rdi, rax
    xor esi, esi
    mov eax, SYS_OPEN
    syscall
    test rax, rax
    js .none
    mov r12, rax
    mov rdi, r12
    lea rsi, [buf]
    mov edx, BUFSZ
    xor eax, eax
    syscall
    mov r13, rax
    mov rdi, r12
    mov eax, 3
    syscall
    test r13, r13
    jle .none
    lea rsi, [buf]
    lea r8, [rsi+r13]
.entry:
    lea rdx, [rsi+4]
    cmp rdx, r8
    ja .none
    movzx eax, word [rsi+2]
    rol ax, 8
    lea rsi, [rsi+rax+4]
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    xor ebx, ebx
    cmp ecx, 1
    jne .fname
    cmp byte [rsi+2], DISPCH
    sete bl
.fname:
    mov rsi, r10
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    test ebx, ebx
    jz .fdata
    cmp ecx, 18
    jne .nomatch
    lea rdi, [rsi+2]
    lea r9, [mit_name]
.m: mov al, [rdi]
    cmp al, [r9]
    jne .nomatch
    inc rdi
    inc r9
    dec ecx
    jnz .m
    jmp .fdata
.nomatch:
    xor ebx, ebx
.fdata:
    mov rsi, r10
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    test ebx, ebx
    jz .next
    cmp ecx, 16
    jne .next
    lea rdi, [hs_buf]
    mov rax, [rsi+2]
    mov [rdi+32], rax
    mov rax, [rsi+10]
    mov [rdi+40], rax
    mov eax, 1
    jmp .out
.next:
    mov rsi, r10
    cmp rsi, r8
    jb .entry
.none:
    xor eax, eax
.out:
    pop r13
    pop r12
    pop rbx
    ret

ctx_save:
    mov eax, [cur]
    lea rdx, [roots]
    mov ecx, [root_node]
    mov [rdx+rax*4], ecx
    lea rdx, [foci]
    mov ecx, [focus]
    mov [rdx+rax*4], ecx
    ret

ctx_load:
    mov [cur], edi
    mov eax, edi
    lea rdx, [roots]
    mov ecx, [rdx+rax*4]
    mov [root_node], ecx
    lea rdx, [foci]
    mov ecx, [rdx+rax*4]
    mov [focus], ecx
    ret

node_tag:
    mov eax, edi
    lea rdx, [nodes]
.u: mov ecx, eax
    shl ecx, 5
    mov esi, [rdx+rcx+N_PAR]
    cmp esi, -1
    je .r
    mov eax, esi
    jmp .u
.r: mov r8d, eax
    call ctx_save
    lea rdx, [roots]
    xor eax, eax
.t: cmp eax, NTAGS
    jge .no
    cmp [rdx+rax*4], r8d
    je .ret
    inc eax
    jmp .t
.no:
    mov eax, -1
.ret:
    ret

remove_any:
    push rbx
    push r12
    mov ebx, edi
    call node_tag
    cmp eax, -1
    je .o
    cmp eax, [cur]
    je .cur
    mov r12d, [cur]
    mov edi, eax
    call ctx_load
    mov byte [quiet], 1
    mov edi, ebx
    call remove_leaf
    mov byte [quiet], 0
    call ctx_save
    mov edi, r12d
    call ctx_load
    jmp .done
.cur:
    mov edi, ebx
    call remove_leaf
    call ewmh_active
.done:
    call ewmh_clients
.o: pop r12
    pop rbx
    ret

unmap_window:
    lea rsi, [req]
    mov byte [rsi], 10
    mov byte [rsi+1], 0
    mov word [rsi+2], 2
    mov [rsi+4], edi
    mov edx, 8
    jmp send

tag_visit:
    cmp edi, -1
    je .r
    push rbx
    push r12
    mov ebx, edi
    mov r12d, esi
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    cmp dword [rdx+rax+N_WIN], 0
    je .int
    mov edi, [rdx+rax+N_WIN]
    test r12d, r12d
    jz .hide
    call map_window
    jmp .o
.hide:
    inc byte [rdx+rax+N_FLG]
    call unmap_window
    jmp .o
.int:
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    call tag_visit
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    mov esi, r12d
    call tag_visit
.o: pop r12
    pop rbx
.r: ret

float_visit:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    xor ebx, ebx
.l: cmp ebx, FLN
    jge .o
    lea rdx, [flt]
    mov eax, ebx
    shl eax, 4
    cmp dword [rdx+rax], 0
    je .n
    cmp [rdx+rax+4], r12d
    jne .n
    mov edi, [rdx+rax]
    test r13d, r13d
    jz .h
    call map_window
    jmp .n
.h: inc dword [rdx+rax+8]
    call unmap_window
.n: inc ebx
    jmp .l
.o: pop r13
    pop r12
    pop rbx
    ret

switch_tag:
    push rbx
    mov ebx, edi
    cmp ebx, NTAGS
    jae .r
    cmp ebx, [cur]
    je .r
    call ctx_save
    mov edi, [root_node]
    xor esi, esi
    call tag_visit
    mov edi, [cur]
    xor esi, esi
    call float_visit
    mov edi, ebx
    call ctx_load
    mov edi, [root_node]
    mov esi, 1
    call tag_visit
    mov edi, [cur]
    mov esi, 1
    call float_visit
    call relayout
    mov dword [fwin], 0
    mov edi, [focus]
    cmp edi, -1
    je .nof
    call set_focus
    jmp .done
.nof:
    mov edi, 1
    call send_focus
    call ewmh_active
.done:
    call ewmh_desktop
.r: pop rbx
    ret

move_to_tag:
    push rbx
    push r12
    push r13
    mov r12d, edi
    cmp r12d, NTAGS
    jae .o
    cmp r12d, [cur]
    je .o
    mov edi, [fwin]
    test edi, edi
    jz .tiled
    call fl_find
    cmp eax, -1
    je .tiled
    lea rdx, [flt]
    shl eax, 4
    mov [rdx+rax+4], r12d
    inc dword [rdx+rax+8]
    mov edi, [fwin]
    mov esi, COL_UNFOC
    call send_border
    mov edi, [fwin]
    call unmap_window
    mov dword [fwin], 0
    mov edi, [focus]
    cmp edi, -1
    je .fnof
    call set_focus
    jmp .o
.fnof:
    mov edi, 1
    call send_focus
    call ewmh_active
    jmp .o
.tiled:
    mov ebx, [focus]
    cmp ebx, -1
    je .o
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov r13d, [rdx+rax+N_WIN]
    test r13d, r13d
    jz .o
    test dword [rdx+rax+N_FLG], FL_FS
    jz .nf
    mov edi, ebx
    xor esi, esi
    call set_fs
.nf:
    mov edi, ebx
    call remove_leaf
    mov ebx, [cur]
    call ctx_save
    mov edi, r12d
    call ctx_load
    mov byte [quiet], 1
    mov edi, r13d
    call add_window
    mov byte [quiet], 0
    call ctx_save
    mov edi, ebx
    call ctx_load
    call ewmh_clients
    call ewmh_active
.o: pop r13
    pop r12
    pop rbx
    ret

show_all:
    lea rdx, [nodes]
    xor ecx, ecx
.n: cmp ecx, MAXN
    jge .f
    mov eax, ecx
    shl eax, 5
    cmp dword [rdx+rax+N_USED], 0
    je .nx
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nx
    push rcx
    call map_window
    pop rcx
    lea rdx, [nodes]
.nx:inc ecx
    jmp .n
.f: xor ecx, ecx
.g: cmp ecx, FLN
    jge .r
    lea rdx, [flt]
    mov eax, ecx
    shl eax, 4
    mov edi, [rdx+rax]
    test edi, edi
    jz .gx
    push rcx
    call map_window
    pop rcx
.gx:inc ecx
    jmp .g
.r: ret

set_prop:
    push rbx
    push r12
    mov r12d, ecx
    lea rbx, [buf]
    mov byte [rbx], 18
    mov byte [rbx+1], 0
    mov [rbx+4], edi
    mov [rbx+8], esi
    mov [rbx+12], edx
    mov byte [rbx+16], r12b
    mov byte [rbx+17], 0
    mov word [rbx+18], 0
    mov [rbx+20], r8d
    mov eax, r8d
    imul eax, r12d
    shr eax, 3
    test r9, r9
    jz .nc
    mov rsi, r9
    lea rdi, [rbx+24]
    mov ecx, eax
    rep movsb
.nc:
    add eax, 3
    and eax, -4
    add eax, 24
    mov edx, eax
    shr eax, 2
    mov [rbx+2], ax
    mov rsi, rbx
    pop r12
    pop rbx
    jmp send

set_wmstate:
    mov r8d, esi
    mov esi, [atoms+AT_STATE*4]
    mov edx, 4
    mov ecx, 32
    lea r9, [atoms+AT_FULL*4]
    jmp set_prop

set_fs:
    push rbx
    mov ebx, edi
    lea rdx, [nodes]
    mov eax, edi
    shl eax, 5
    and dword [rdx+rax+N_FLG], ~FL_FS
    test esi, esi
    jz .a
    or dword [rdx+rax+N_FLG], FL_FS
.a: mov edi, [rdx+rax+N_WIN]
    call set_wmstate
    pop rbx
    ret

toggle_fs:
    mov eax, [focus]
    cmp eax, -1
    je .r
    mov edi, eax
    lea rdx, [nodes]
    shl eax, 5
    mov esi, [rdx+rax+N_FLG]
    shr esi, 8
    and esi, 1
    xor esi, 1
    call set_fs
    jmp relayout
.r: ret

ewmh_desktop:
    mov edi, [root]
    mov esi, [atoms+AT_CDESK*4]
    mov edx, 6
    mov ecx, 32
    mov r8d, 1
    lea r9, [cur]
    jmp set_prop

ewmh_active:
    mov eax, [fwin]
    test eax, eax
    jnz .s
    mov eax, [focus]
    cmp eax, -1
    je .none
    lea rdx, [nodes]
    shl eax, 5
    mov eax, [rdx+rax+N_WIN]
    jmp .s
.none:
    xor eax, eax
.s: mov [actwin], eax
    mov edi, [root]
    mov esi, [atoms+AT_ACTIVE*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [actwin]
    jmp set_prop

ewmh_clients:
    lea rdi, [buf+1024]
    xor ecx, ecx
    lea rdx, [nodes]
    xor esi, esi
.n: cmp esi, MAXN
    jge .f
    mov eax, esi
    shl eax, 5
    cmp dword [rdx+rax+N_USED], 0
    je .nx
    mov r8d, [rdx+rax+N_WIN]
    test r8d, r8d
    jz .nx
    mov [rdi+rcx*4], r8d
    inc ecx
.nx:inc esi
    jmp .n
.f: lea rdx, [flt]
    xor esi, esi
.g: cmp esi, FLN
    jge .d
    mov eax, esi
    shl eax, 4
    mov r8d, [rdx+rax]
    test r8d, r8d
    jz .gx
    mov [rdi+rcx*4], r8d
    inc ecx
.gx:inc esi
    jmp .g
.d: mov r8d, ecx
    mov r9, rdi
    mov edi, [root]
    mov esi, [atoms+AT_CLIENTS*4]
    mov edx, 33
    mov ecx, 32
    jmp set_prop

intern_all:
    push rbx
    push r12
    push r13
    lea rbx, [atom_names]
    xor r12d, r12d
.n: cmp byte [rbx], 0
    je .o
    xor ecx, ecx
.l: cmp byte [rbx+rcx], 0
    je .e
    inc ecx
    jmp .l
.e: mov r13d, ecx
    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 16
    mov [rdi+4], r13w
    lea eax, [r13+3]
    shr eax, 2
    add eax, 2
    mov [rdi+2], ax
    lea edx, [rax*4]
    push rdx
    lea rdi, [req+8]
    mov rsi, rbx
    mov ecx, r13d
    rep movsb
    lea rsi, [req]
    pop rdx
    call send
    mov rdi, [fd]
    lea rsi, [ev]
    mov edx, 32
    call read_exact
    test rax, rax
    jnz fail_read
    mov eax, [ev+8]
    lea rdx, [atoms]
    mov [rdx+r12*4], eax
    inc r12d
    lea rbx, [rbx+r13+1]
    jmp .n
.o: pop r13
    pop r12
    pop rbx
    ret

ewmh_init:

    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 1
    mov word [rdi+2], 8
    mov eax, [rid_base]
    or eax, 1
    mov [wmcheck], eax
    mov [rdi+4], eax
    mov eax, [root]
    mov [rdi+8], eax
    mov word [rdi+16], 1
    mov word [rdi+18], 1
    mov word [rdi+22], 2
    mov rsi, rdi
    mov edx, 32
    call send

    mov edi, [root]
    mov esi, [atoms+AT_CHECK*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [wmcheck]
    call set_prop
    mov edi, [wmcheck]
    mov esi, [atoms+AT_CHECK*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [wmcheck]
    call set_prop
    mov edi, [wmcheck]
    mov esi, [atoms+AT_WMNAME*4]
    mov edx, [atoms+AT_UTF8*4]
    mov ecx, 8
    mov r8d, WM_NAME_LEN
    lea r9, [wm_name]
    call set_prop

    mov edi, [root]
    mov esi, [atoms+AT_SUPPORTED*4]
    mov edx, 4
    mov ecx, 32
    mov r8d, 15
    lea r9, [atoms+AT_CHECK*4]
    call set_prop

    mov edi, [root]
    mov esi, [atoms+AT_NDESK*4]
    mov edx, 6
    mov ecx, 32
    mov r8d, 1
    lea r9, [ntags]
    call set_prop
    call ewmh_desktop
    call ewmh_clients
    jmp ewmh_active

wait_reply:
    push rbx
    movzx ebx, word [seq]
.again:
    mov rdi, [fd]
    lea rsi, [rbuf]
    mov edx, 32
    call read_exact
    test rax, rax
    jnz fail_read
    movzx eax, byte [rbuf]
    cmp eax, 1
    je .reply
    test eax, eax
    jz .err
    and eax, 0x7f
    cmp eax, 20
    je .queue
    lea rsi, [rbuf]
    lea rdi, [ev]
    mov ecx, 4
    rep movsq
    call handle_event
    jmp .again
.queue:
    mov eax, [evq_n]
    cmp eax, 8
    jae .again
    add eax, [evq_h]
    and eax, 7
    shl eax, 5
    lea rdi, [evq]
    add rdi, rax
    lea rsi, [rbuf]
    mov ecx, 4
    rep movsq
    inc dword [evq_n]
    jmp .again
.err:
    movzx eax, word [rbuf+2]
    cmp eax, ebx
    jne .again
    xor eax, eax
    jmp .o
.reply:
    mov ecx, [rbuf+4]
    test ecx, ecx
    jz .noextra
    shl ecx, 2
    cmp ecx, 256
    ja fail_read
    mov edx, ecx
    mov rdi, [fd]
    lea rsi, [xbuf]
    call read_exact
    test rax, rax
    jnz fail_read
.noextra:
    movzx eax, word [rbuf+2]
    cmp eax, ebx
    jne .again
    mov eax, 1
.o: pop rbx
    ret

get_prop:
    lea rax, [req]
    mov qword [rax], 0
    mov qword [rax+8], 0
    mov qword [rax+16], 0
    mov byte [rax], 20
    mov word [rax+2], 6
    mov [rax+4], edi
    mov [rax+8], esi
    mov [rax+12], edx
    mov [rax+20], ecx
    mov rsi, rax
    mov edx, 24
    call send
    jmp wait_reply

classify_win:
    push rbx
    mov ebx, edi
    mov esi, 68
    xor edx, edx
    mov ecx, 1
    call get_prop
    test eax, eax
    jz .gone
    cmp dword [rbuf+8], 0
    jne .float
    mov edi, ebx
    mov esi, [atoms+AT_WTYPE*4]
    mov edx, 4
    mov ecx, 8
    call get_prop
    test eax, eax
    jz .gone
    mov ecx, [rbuf+16]
    cmp ecx, 8
    jbe .c
    mov ecx, 8
.c: lea rsi, [xbuf]
.t: test ecx, ecx
    jz .tiled
    mov eax, [rsi]
    cmp eax, [atoms+AT_DIALOG*4]
    je .float
    cmp eax, [atoms+AT_SPLASH*4]
    je .float
    cmp eax, [atoms+AT_UTIL*4]
    je .float
    cmp eax, [atoms+AT_DOCK*4]
    je .dock
    add rsi, 4
    dec ecx
    jmp .t
.tiled:
    xor eax, eax
    jmp .o
.float:
    mov eax, 1
    jmp .o
.dock:

    mov edi, ebx
    mov esi, [atoms+AT_STRUT*4]
    mov edx, 6
    mov ecx, 12
    call get_prop
    test eax, eax
    jz .legacystrut

    cmp dword [rbuf+16], 3
    jae .partialok
.legacystrut:

    mov edi, ebx
    mov esi, [atoms+AT_STRUT_OLD*4]
    mov edx, 6
    mov ecx, 4
    call get_prop
    test eax, eax
    jz .nostrut
    cmp dword [rbuf+16], 3
    jb .nostrut
.partialok:
    mov eax, [xbuf+8]
    jmp .strutdone
.nostrut:
    xor eax, eax
.strutdone:
    mov [bar_top], eax
    mov [bar_win], ebx
    mov eax, 2
    jmp .o
.gone:
    mov eax, -1
.o: pop rbx
    ret

fl_find:
    test edi, edi
    jz .no
    lea rdx, [flt]
    xor eax, eax
.l: cmp eax, FLN
    jge .no
    mov ecx, eax
    shl ecx, 4
    cmp [rdx+rcx], edi
    je .ret
    inc eax
    jmp .l
.no:
    mov eax, -1
.ret:
    ret

fl_add:
    lea rdx, [flt]
    xor eax, eax
.l: cmp eax, FLN
    jge .no
    mov ecx, eax
    shl ecx, 4
    cmp dword [rdx+rcx], 0
    je .f
    inc eax
    jmp .l
.f: mov [rdx+rcx], edi
    mov [rdx+rcx+4], esi
    mov dword [rdx+rcx+8], 0
    ret
.no:
    mov eax, -1
    ret

set_attrs:
    lea rsi, [req]
    mov byte [rsi], 2
    mov byte [rsi+1], 0
    mov word [rsi+2], 5
    mov [rsi+4], edi
    mov dword [rsi+8], 0x808
    mov dword [rsi+12], COL_UNFOC
    mov dword [rsi+16], ENTER_MASK
    mov edx, 20
    jmp send

focus_float:
    push rbx
    mov ebx, edi
    mov eax, [focus]
    cmp eax, -1
    je .nt
    lea rdx, [nodes]
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nt
    mov esi, COL_UNFOC
    call send_border
.nt:
    mov edi, [fwin]
    test edi, edi
    jz .nf
    cmp edi, ebx
    je .nf
    mov esi, COL_UNFOC
    call send_border
.nf:
    mov [fwin], ebx
    mov edi, ebx
    mov esi, COL_FOC
    call send_border
    mov edi, ebx
    call send_focus
    call ewmh_active
    pop rbx
    ret

float_window:
    push rbx
    mov ebx, edi
    mov esi, [cur]
    call fl_add
    cmp eax, -1
    je .map
    mov edi, ebx
    call set_attrs
    lea rdi, [req]
    mov byte [rdi], 14
    mov byte [rdi+1], 0
    mov word [rdi+2], 2
    mov [rdi+4], ebx
    mov rsi, rdi
    mov edx, 8
    call send
    call wait_reply
    test eax, eax
    jz .map
    movzx eax, word [rbuf+16]
    movzx ecx, word [rbuf+18]
    lea rdi, [req]
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov word [rdi+2], 7
    mov [rdi+4], ebx
    mov word [rdi+8], 0x53
    mov word [rdi+10], 0
    mov edx, [scrw]
    sub edx, eax
    jns .x1
    xor edx, edx
.x1:shr edx, 1
    mov [rdi+12], edx
    mov edx, [scrh]
    sub edx, ecx
    jns .y1
    xor edx, edx
.y1:shr edx, 1
    mov [rdi+16], edx
    mov dword [rdi+20], BW
    mov dword [rdi+24], 0
    mov rsi, rdi
    mov edx, 28
    call send
.map:
    mov edi, ebx
    call map_window
    mov edi, ebx
    call focus_float
    call ewmh_clients
    pop rbx
    ret

fwd_configure:
    lea rdi, [req]
    movzx ecx, word [ev+26]
    and ecx, 0xf
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov eax, [ev+8]
    mov [rdi+4], eax
    mov [rdi+8], cx
    mov word [rdi+10], 0
    lea rsi, [rdi+12]
    test ecx, 1
    jz .y
    movsx eax, word [ev+16]
    mov [rsi], eax
    add rsi, 4
.y: test ecx, 2
    jz .w
    movsx eax, word [ev+18]
    mov [rsi], eax
    add rsi, 4
.w: test ecx, 4
    jz .h
    movzx eax, word [ev+20]
    mov [rsi], eax
    add rsi, 4
.h: test ecx, 8
    jz .s
    movzx eax, word [ev+22]
    mov [rsi], eax
    add rsi, 4
.s: mov rdx, rsi
    sub rdx, rdi
    mov eax, edx
    shr eax, 2
    mov [rdi+2], ax
    mov rsi, rdi
    jmp send

handle_event:
    push rbx
    push r12
    push r13
    push r14
    push r15
    movzx eax, byte [ev]
    and eax, 0x7f
    test eax, eax
    jz .xerr
    cmp eax, 20
    je .maprq
    cmp eax, 23
    je .cfgrq
    cmp eax, 17
    je .gone
    cmp eax, 18
    je .gone
    cmp eax, 7
    je .enter
    cmp eax, 2
    je .key
    cmp eax, 33
    je .cm
.evdone:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.xerr:
    cmp byte [ev+10], 33
    jne .evdone
    cmp byte [ev+1], 10
    jne .evdone
    cmp byte [grab_warned], 0
    jne .evdone
    mov byte [grab_warned], 1
    lea rsi, [msg_grab]
    mov edx, MSG_GRAB_LEN
    call write_out
    jmp .evdone

.maprq:
    mov r12d, [ev+8]
    mov edi, r12d
    call find_win
    cmp eax, -1
    jne .known
    mov edi, r12d
    call fl_find
    cmp eax, -1
    jne .fknown
    mov edi, r12d
    call classify_win
    cmp eax, -1
    je .evdone
    cmp eax, 2
    je .isdock
    test eax, eax
    jnz .isfloat
    mov edi, r12d
    call add_window
    jmp .evdone
.isfloat:
    mov edi, r12d
    call float_window
    jmp .evdone
.isdock:
    mov edi, r12d
    call map_window
    call relayout
    call ewmh_clients
    jmp .evdone
.known:
    mov edi, eax
    call node_tag
    cmp eax, [cur]
    jne .evdone
    mov edi, r12d
    call map_window
    jmp .evdone
.fknown:
    lea rdx, [flt]
    shl eax, 4
    mov ecx, [rdx+rax+4]
    cmp ecx, [cur]
    jne .evdone
    mov edi, r12d
    call map_window
    jmp .evdone

.cfgrq:
    mov edi, [ev+8]
    call find_win
    cmp eax, -1
    jne .tcfg
    call fwd_configure
    jmp .evdone
.tcfg:
    call relayout
    jmp .evdone

.gone:

    mov eax, [ev+8]
    cmp eax, [bar_win]
    jne .notdockgone
    mov dword [bar_win], 0
    mov dword [bar_top], 0
    call relayout
.notdockgone:
    movzx r13d, byte [ev]
    and r13d, 0x7f
    mov r12d, [ev+8]
    mov edi, r12d
    call find_win
    cmp eax, -1
    je .gfloat
    cmp r13d, 18
    jne .gdel
    lea rdx, [nodes]
    mov ecx, eax
    shl ecx, 5
    cmp byte [rdx+rcx+N_FLG], 0
    je .gdel
    dec byte [rdx+rcx+N_FLG]
    jmp .evdone
.gdel:
    mov edi, eax
    call remove_any
    jmp .evdone
.gfloat:
    mov edi, r12d
    call fl_find
    cmp eax, -1
    je .evdone
    lea rdx, [flt]
    mov ecx, eax
    shl ecx, 4
    cmp r13d, 18
    jne .fdel
    cmp dword [rdx+rcx+8], 0
    je .fdel
    dec dword [rdx+rcx+8]
    jmp .evdone
.fdel:
    mov dword [rdx+rcx], 0
    call ewmh_clients
    cmp [fwin], r12d
    jne .evdone
    mov dword [fwin], 0
    mov edi, [focus]
    cmp edi, -1
    je .nofoc
    call set_focus
    jmp .evdone
.nofoc:
    call ewmh_active
    jmp .evdone

.enter:
    cmp byte [ev+30], 0
    jne .evdone
    mov edi, [ev+12]
    call find_win
    cmp eax, -1
    jne .etile
    mov edi, [ev+12]
    call fl_find
    cmp eax, -1
    je .evdone
    mov edi, [ev+12]
    call focus_float
    jmp .evdone
.etile:
    cmp eax, [focus]
    jne .doset
    cmp dword [fwin], 0
    je .evdone
.doset:
    mov edi, eax
    call set_focus
    jmp .evdone

.cm:
    mov eax, [ev+8]
    cmp eax, [atoms+AT_STATE*4]
    je .cm_state
    cmp eax, [atoms+AT_CDESK*4]
    je .cm_desk
    cmp eax, [atoms+AT_ACTIVE*4]
    je .cm_act
    jmp .evdone
.cm_state:
    mov eax, [atoms+AT_FULL*4]
    cmp [ev+16], eax
    je .cm_fs
    cmp [ev+20], eax
    jne .evdone
.cm_fs:
    mov edi, [ev+4]
    call find_win
    cmp eax, -1
    je .evdone
    mov ebx, eax
    mov ecx, [ev+12]
    cmp ecx, 2
    jne .cmset
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov ecx, [rdx+rax+N_FLG]
    shr ecx, 8
    and ecx, 1
    xor ecx, 1
.cmset:
    mov edi, ebx
    mov esi, ecx
    call set_fs
    call relayout
    jmp .evdone
.cm_desk:
    mov edi, [ev+12]
    call switch_tag
    jmp .evdone
.cm_act:
    mov edi, [ev+4]
    call find_win
    cmp eax, -1
    je .evdone
    mov ebx, eax
    mov edi, ebx
    call node_tag
    cmp eax, -1
    je .evdone
    mov edi, eax
    call switch_tag
    mov edi, ebx
    call set_focus
    jmp .evdone

.key:
    movzx ecx, byte [ev+1]
    movzx edx, word [ev+28]
    and edx, 0xED
    lea rsi, [keytab]
    mov edi, KEYS_N
.ks:
    cmp cl, [rsi]
    jne .kn
    movzx eax, byte [rsi+1]
    add eax, MODK
    cmp eax, edx
    jne .kn
    movzx eax, byte [rsi+2]
    jmp .act
.kn:
    add rsi, 3
    dec edi
    jnz .ks
    jmp .evdone
.act:
    cmp eax, 32
    jb .nomv
    sub eax, 32
    mov edi, eax
    call move_to_tag
    jmp .evdone
.nomv:
    cmp eax, 16
    jb .chain
    sub eax, 16
    mov edi, eax
    call switch_tag
    jmp .evdone
.chain:
    cmp eax, A_TERM
    jne .a1
    lea rdi, [cmd_term]
    call spawn
    jmp .evdone
.a1:
    cmp eax, A_CLOSE
    jne .a2
    call close_focused
    jmp .evdone
.a2:
    cmp eax, A_NEXT
    jne .a3
    mov edi, 1
    call cycle_focus
    jmp .evdone
.a3:
    cmp eax, A_PREV
    jne .a4
    mov edi, -1
    call cycle_focus
    jmp .evdone
.a4:
    cmp eax, A_SHRINK
    jne .a5
    mov edi, -RESIZE_STEP
    call resize_focused
    jmp .evdone
.a5:
    cmp eax, A_GROW
    jne .a6
    mov edi, RESIZE_STEP
    call resize_focused
    jmp .evdone
.a6:
    cmp eax, A_FLIP
    jne .a7
    call flip_parent
    jmp .evdone
.a7:
    cmp eax, A_DMENU
    jne .a8
    lea rdi, [cmd_menu]
    call spawn
    jmp .evdone
.a8:
    cmp eax, A_BALANCE
    jne .a9
    call balance
    jmp .evdone
.a9:
    cmp eax, A_SWAPN
    jne .a10
    mov edi, 1
    call swap_focused
    jmp .evdone
.a10:
    cmp eax, A_SWAPP
    jne .a11
    mov edi, -1
    call swap_focused
    jmp .evdone
.a11:
    cmp eax, A_FULL
    jne .a12
    call toggle_fs
    jmp .evdone
.a12:
    cmp eax, A_KILL
    jne .a13
    call kill_focused
    jmp .evdone
.a13:
    cmp eax, A_QUIT
    jne .evdone
    call show_all
    xor edi, edi
    mov eax, SYS_EXIT
    syscall

_start:
    mov [init_sp], rsp
    call build_env
    mov edi, 17
    lea rsi, [sig_ign]
    xor edx, edx
    mov r10d, 8
    mov eax, SYS_SIGACT
    syscall

    mov eax, SYS_SOCKET
    mov edi, 1
    mov esi, 1
    xor edx, edx
    syscall
    test rax, rax
    js fail_sock
    mov [fd], rax

    mov rdi, rax
    lea rsi, [sockaddr]
    mov edx, SOCKADDR_LEN
    mov eax, SYS_CONNECT
    syscall
    test rax, rax
    js fail_conn

    call load_auth
    lea rdi, [hs_buf]
    mov byte [rdi], 'l'
    mov word [rdi+2], 11
    mov edx, 12
    test eax, eax
    jz .noauth
    mov word [rdi+6], 18
    mov word [rdi+8], 16
    lea rsi, [mit_name]
    lea rdi, [hs_buf+12]
    mov ecx, 18
    rep movsb
    mov edx, 48
.noauth:
    mov rdi, [fd]
    lea rsi, [hs_buf]
    mov eax, SYS_WRITE
    syscall

    mov rdi, [fd]
    lea rsi, [buf]
    mov edx, 8
    call read_exact
    test rax, rax
    jnz fail_read

    movzx edx, word [buf+6]
    shl edx, 2
    cmp edx, BUFSZ-8
    ja fail_big
    mov rdi, [fd]
    lea rsi, [buf+8]
    call read_exact
    test rax, rax
    jnz fail_read

    cmp byte [buf], 1
    jne refused

    movzx eax, word [buf+24]
    add eax, 3
    and eax, -4
    movzx ecx, byte [buf+29]
    shl ecx, 3
    lea ebx, [rax+rcx+40]
    lea r12, [buf]
    add r12, rbx
    mov eax, [buf+12]
    mov [rid_base], eax
    mov eax, [r12]
    mov [root], eax
    movzx eax, word [r12+20]
    mov [scrw], eax
    movzx eax, word [r12+22]
    mov [scrh], eax

    call intern_all

    lea rdi, [req]
    mov byte [rdi], 2
    mov byte [rdi+1], 0
    mov word [rdi+2], 4
    mov eax, [root]
    mov [rdi+4], eax
    mov dword [rdi+8], 0x800
    mov dword [rdi+12], 0x180000
    mov byte [rdi+16], 43
    mov byte [rdi+17], 0
    mov word [rdi+18], 1
    mov rsi, rdi
    mov edx, 20
    inc word [seq]
    call send

    mov rdi, [fd]
    lea rsi, [ev]
    mov edx, 32
    call read_exact
    test rax, rax
    jnz fail_read
    cmp byte [ev], 0
    je other_wm

    lea rsi, [msg_wm]
    mov edx, MSG_WM_LEN
    call write_out
    call ewmh_init
    call grab_keys

.loop:
    mov eax, [evq_n]
    test eax, eax
    jz .rd
    mov eax, [evq_h]
    shl eax, 5
    lea rsi, [evq]
    add rsi, rax
    lea rdi, [ev]
    mov ecx, 4
    rep movsq
    mov eax, [evq_h]
    inc eax
    and eax, 7
    mov [evq_h], eax
    dec dword [evq_n]
    jmp .disp
.rd:
    mov rdi, [fd]
    lea rsi, [ev]
    mov edx, 32
    call read_exact
    test rax, rax
    jnz fail_read
.disp:
    call handle_event
    jmp .loop

other_wm:
    lea rsi, [msg_other]
    mov edx, MSG_OTHER_LEN
    call write_out
    jmp fail_exit

refused:
    lea rsi, [msg_refused]
    mov edx, MSG_REFUSED_LEN
    call write_out
    lea rsi, [buf+8]
    movzx edx, byte [buf+1]
    call write_out
    lea rsi, [msg_nl]
    mov edx, 1
    call write_out
    jmp fail_exit

fail_sock:
    lea rsi, [err_sock]
    mov edx, ERR_SOCK_LEN
    call write_out
    jmp fail_exit
fail_conn:
    lea rsi, [err_conn]
    mov edx, ERR_CONN_LEN
    call write_out
    jmp fail_exit
fail_big:
    lea rsi, [err_big]
    mov edx, ERR_BIG_LEN
    call write_out
    jmp fail_exit
fail_read:
    lea rsi, [err_read]
    mov edx, ERR_READ_LEN
    call write_out
fail_exit:
    mov edi, 1
    mov eax, SYS_EXIT
    syscall
