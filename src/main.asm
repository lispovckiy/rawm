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
