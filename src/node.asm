alloc_node:
    lea rdx, [nodes]
    xor eax, eax
.l: cmp eax, MAXN
    jge .none
    mov ecx, eax
    shl ecx, 5
    cmp dword [rdx+rcx+N_USED], 0
    je .found
    inc eax
    jmp .l
.found:
    mov dword [rdx+rcx+N_RAT], 500
    mov dword [rdx+rcx+N_USED], 1
    mov qword [rdx+rcx+N_WIN], 0
    mov dword [rdx+rcx+N_PAR], -1
    mov dword [rdx+rcx+N_L], -1
    mov dword [rdx+rcx+N_R], -1
    mov dword [rdx+rcx+N_DIR], 0
    ret
.none:
    mov eax, -1
    ret

find_win:
    lea rdx, [nodes]
    xor eax, eax
.l: cmp eax, MAXN
    jge .none
    mov ecx, eax
    shl ecx, 5
    cmp dword [rdx+rcx+N_USED], 0
    je .n
    cmp dword [rdx+rcx+N_WIN], edi
    je .ret
.n: inc eax
    jmp .l
.none:
    mov eax, -1
.ret:
    ret

split_sz:
    mov eax, edi
    imul eax, esi
    xor edx, edx
    mov ecx, 1000
    div ecx
    ret
