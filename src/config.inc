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
A_SHOT      equ 14

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
