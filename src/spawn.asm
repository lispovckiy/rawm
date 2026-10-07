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
