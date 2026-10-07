target_window:
    mov eax, [fwin]
    test eax, eax
    jnz .r
    mov eax, [focus]
    cmp eax, -1
    je .none
    lea rdx, [nodes]
    shl eax, 5
    mov eax, [rdx+rax+N_WIN]
    ret
.none:
    xor eax, eax
.r: ret

kill_focused:
    call target_window
    test eax, eax
    jz .r
    lea rsi, [req]
    mov byte [rsi], 113
    mov byte [rsi+1], 0
    mov word [rsi+2], 2
    mov [rsi+4], eax
    mov edx, 8
    jmp send
.r: ret

close_focused:
    call target_window
    test eax, eax
    jz .r
    mov r8d, eax
    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 25
    mov byte [rdi+1], 0
    mov word [rdi+2], 11
    mov [rdi+4], r8d
    mov dword [rdi+8], 0
    mov byte [rdi+12], 33
    mov byte [rdi+13], 32
    mov [rdi+16], r8d
    mov eax, [atoms+AT_PROTO*4]
    mov [rdi+20], eax
    mov eax, [atoms+AT_DELETE*4]
    mov [rdi+24], eax
    mov rsi, rdi
    mov edx, 44
    jmp send
.r: ret

next_leaf:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov ebx, [focus]
    cmp ebx, -1
    je .none
    mov r13d, MAXN
.n: add ebx, r12d
    and ebx, MAXN-1
    lea rdx, [nodes]
    mov esi, ebx
    shl esi, 5
    cmp dword [rdx+rsi+N_USED], 0
    je .skip
    cmp dword [rdx+rsi+N_WIN], 0
    je .skip
    mov edi, ebx
    call node_tag
    cmp eax, [cur]
    jne .skip
    mov eax, ebx
    jmp .o
.skip:
    dec r13d
    jnz .n
.none:
    mov eax, -1
.o: pop r13
    pop r12
    pop rbx
    ret

cycle_focus:
    call next_leaf
    cmp eax, -1
    je .r
    mov edi, eax
    jmp set_focus
.r: ret

swap_focused:
    push rbx
    mov ebx, [focus]
    cmp ebx, -1
    je .r
    call next_leaf
    cmp eax, -1
    je .r
    cmp eax, ebx
    je .r
    lea rdx, [nodes]
    mov ecx, ebx
    shl ecx, 5
    mov esi, eax
    shl esi, 5
    mov r8, [rdx+rcx+N_WIN]
    mov r9, [rdx+rsi+N_WIN]
    mov [rdx+rcx+N_WIN], r9
    mov [rdx+rsi+N_WIN], r8
    mov ebx, eax
    call relayout
    mov edi, ebx
    call set_focus
.r: pop rbx
    ret

balance:
    lea rdx, [nodes]
    mov ecx, MAXN
.l: mov dword [rdx+N_RAT], 500
    add rdx, 32
    dec ecx
    jnz .l
    jmp relayout

resize_focused:
    mov eax, [focus]
    cmp eax, -1
    je .r
    lea rdx, [nodes]
    mov esi, eax
    shl esi, 5
    mov ecx, [rdx+rsi+N_PAR]
    cmp ecx, -1
    je .r
    shl ecx, 5
    cmp [rdx+rcx+N_L], eax
    je .left
    neg edi
.left:
    mov eax, [rdx+rcx+N_RAT]
    add eax, edi
    cmp eax, 100
    jge .a
    mov eax, 100
.a: cmp eax, 900
    jle .b
    mov eax, 900
.b: mov [rdx+rcx+N_RAT], eax
    jmp relayout
.r: ret

flip_parent:
    mov eax, [focus]
    cmp eax, -1
    je .r
    lea rdx, [nodes]
    shl eax, 5
    mov ecx, [rdx+rax+N_PAR]
    cmp ecx, -1
    je .r
    shl ecx, 5
    xor dword [rdx+rcx+N_DIR], 1
    jmp relayout
.r: ret
