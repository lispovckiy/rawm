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

%include "src/keytab.inc"

lockvars:   dw 0, 0x02, 0x10, 0x12

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
