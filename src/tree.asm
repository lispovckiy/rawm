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
