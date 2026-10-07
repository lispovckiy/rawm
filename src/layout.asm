layout:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov ebx, edi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx
    mov r15d, r8d
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    cmp dword [rdx+rax+N_WIN], 0
    je .internal

    mov ecx, [rdx+rax+N_WIN]
    mov r9d, [rdx+rax+N_FLG]
    lea rdi, [req]
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov word [rdi+2], 8
    mov [rdi+4], ecx
    mov word [rdi+10], 0
    test r9d, FL_FS
    jnz .fullscr
    mov word [rdi+8], 0x1f
    lea eax, [r12+GAP]
    mov [rdi+12], eax
    lea eax, [r13+GAP]
    mov [rdi+16], eax
    mov edx, 1
    lea eax, [r14-(2*GAP+2*BW)]
    cmp eax, 1
    cmovl eax, edx
    mov [rdi+20], eax
    lea eax, [r15-(2*GAP+2*BW)]
    cmp eax, 1
    cmovl eax, edx
    mov [rdi+24], eax
    mov dword [rdi+28], BW
    mov rsi, rdi
    mov edx, 32
    call send
    jmp .out
.fullscr:
    mov word [rdi+2], 9
    mov word [rdi+8], 0x5f
    mov dword [rdi+12], 0
    mov dword [rdi+16], 0
    mov eax, [scrw]
    mov [rdi+20], eax
    mov eax, [scrh]
    mov [rdi+24], eax
    mov dword [rdi+28], 0
    mov dword [rdi+32], 0
    mov rsi, rdi
    mov edx, 36
    call send
    jmp .out

.internal:
    cmp dword [rdx+rax+N_DIR], 0
    jne .horiz

    mov edi, r14d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov ecx, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    mov edx, r13d
    mov r8d, r15d
    call layout

    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, r14d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov ecx, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    lea esi, [r12+rcx]
    neg ecx
    add ecx, r14d
    mov edx, r13d
    mov r8d, r15d
    call layout
    jmp .out

.horiz:

    mov edi, r15d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov r8d, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r14d
    call layout

    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, r15d
    mov esi, [rdx+rax+N_RAT]
    call split_sz
    mov r8d, eax
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    lea edx, [r13+r8]
    neg r8d
    add r8d, r15d
    mov esi, r12d
    mov ecx, r14d
    call layout
.out:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

relayout:
    cmp byte [quiet], 0
    jne .r
    mov edi, [root_node]
    cmp edi, -1
    je .r
    mov esi, OUTER_GAP
    mov edx, OUTER_GAP
    add edx, [bar_top]
    mov ecx, [scrw]
    sub ecx, 2*OUTER_GAP
    mov r8d, [scrh]
    sub r8d, 2*OUTER_GAP
    sub r8d, [bar_top]
    jmp layout
.r: ret
