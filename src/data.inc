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
    db 39, 0, A_SHOT
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

cmd_shot    db "scrot ~/Pictures/%Y-%m-%d_%H%M%S.png", 0
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
