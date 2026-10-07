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
