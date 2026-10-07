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
