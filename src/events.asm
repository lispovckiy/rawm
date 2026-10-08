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
    cmp eax, 25
    jae .chain
    sub eax, 16
    mov edi, eax
    call switch_tag
    jmp .evdone

.chain:
    cmp eax, A_SHOT
    jne .a_vup
    lea rdi, [cmd_shot]
    call spawn
    jmp .evdone
.a_term:
    cmp eax, A_TERM
    jne .a1
    lea rdi, [cmd_term]
    call spawn
    jmp .evdone

.a_vup:
    cmp eax, A_VOLUP
    jne .a_vdn
    lea rdi, [cmd_volup]
    call spawn
    jmp .evdone
.a_vdn:
    cmp eax, A_VOLDN
    jne .a_mute
    lea rdi, [cmd_voldn]
    call spawn
    jmp .evdone
.a_mute:
    cmp eax, A_MUTE
    jne .a_term
    lea rdi, [cmd_mute]
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
