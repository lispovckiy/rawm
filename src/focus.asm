set_focus:
    push rbx
    push r12
    mov ebx, edi
    cmp byte [quiet], 0
    jne .qset
    mov edi, [fwin]
    test edi, edi
    jz .nofw
    mov esi, COL_UNFOC
    call send_border
    mov dword [fwin], 0
.nofw:
    mov eax, [focus]
    cmp eax, -1
    je .nold
    lea rdx, [nodes]
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nold
    mov esi, COL_UNFOC
    call send_border
.nold:
    mov [focus], ebx
    cmp ebx, -1
    je .eact
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .eact
    mov r12d, edi
    mov esi, COL_FOC
    call send_border
    mov edi, r12d
    call send_focus
.eact:
    call ewmh_active
    jmp .out
.qset:
    mov [focus], ebx
.out:
    pop r12
    pop rbx
    ret
