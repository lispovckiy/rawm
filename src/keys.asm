grab_keys:
    push rbx
    push r12
    push r13
    push r14
    lea rbx, [keytab]
    mov r12d, KEYS_N
.key:
    movzx r13d, byte [rbx+1]
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
