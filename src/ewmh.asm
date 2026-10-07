set_prop:
    push rbx
    push r12
    mov r12d, ecx
    lea rbx, [buf]
    mov byte [rbx], 18
    mov byte [rbx+1], 0
    mov [rbx+4], edi
    mov [rbx+8], esi
    mov [rbx+12], edx
    mov byte [rbx+16], r12b
    mov byte [rbx+17], 0
    mov word [rbx+18], 0
    mov [rbx+20], r8d
    mov eax, r8d
    imul eax, r12d
    shr eax, 3
    test r9, r9
    jz .nc
    mov rsi, r9
    lea rdi, [rbx+24]
    mov ecx, eax
    rep movsb
.nc:
    add eax, 3
    and eax, -4
    add eax, 24
    mov edx, eax
    shr eax, 2
    mov [rbx+2], ax
    mov rsi, rbx
    pop r12
    pop rbx
    jmp send

set_wmstate:
    mov r8d, esi
    mov esi, [atoms+AT_STATE*4]
    mov edx, 4
    mov ecx, 32
    lea r9, [atoms+AT_FULL*4]
    jmp set_prop

set_fs:
    push rbx
    mov ebx, edi
    lea rdx, [nodes]
    mov eax, edi
    shl eax, 5
    and dword [rdx+rax+N_FLG], ~FL_FS
    test esi, esi
    jz .a
    or dword [rdx+rax+N_FLG], FL_FS
.a: mov edi, [rdx+rax+N_WIN]
    call set_wmstate
    pop rbx
    ret

toggle_fs:
    mov eax, [focus]
    cmp eax, -1
    je .r
    mov edi, eax
    lea rdx, [nodes]
    shl eax, 5
    mov esi, [rdx+rax+N_FLG]
    shr esi, 8
    and esi, 1
    xor esi, 1
    call set_fs
    jmp relayout
.r: ret

ewmh_desktop:
    mov edi, [root]
    mov esi, [atoms+AT_CDESK*4]
    mov edx, 6
    mov ecx, 32
    mov r8d, 1
    lea r9, [cur]
    jmp set_prop

ewmh_active:
    mov eax, [fwin]
    test eax, eax
    jnz .s
    mov eax, [focus]
    cmp eax, -1
    je .none
    lea rdx, [nodes]
    shl eax, 5
    mov eax, [rdx+rax+N_WIN]
    jmp .s
.none:
    xor eax, eax
.s: mov [actwin], eax
    mov edi, [root]
    mov esi, [atoms+AT_ACTIVE*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [actwin]
    jmp set_prop

ewmh_clients:
    lea rdi, [buf+1024]
    xor ecx, ecx
    lea rdx, [nodes]
    xor esi, esi
.n: cmp esi, MAXN
    jge .f
    mov eax, esi
    shl eax, 5
    cmp dword [rdx+rax+N_USED], 0
    je .nx
    mov r8d, [rdx+rax+N_WIN]
    test r8d, r8d
    jz .nx
    mov [rdi+rcx*4], r8d
    inc ecx
.nx:inc esi
    jmp .n
.f: lea rdx, [flt]
    xor esi, esi
.g: cmp esi, FLN
    jge .d
    mov eax, esi
    shl eax, 4
    mov r8d, [rdx+rax]
    test r8d, r8d
    jz .gx
    mov [rdi+rcx*4], r8d
    inc ecx
.gx:inc esi
    jmp .g
.d: mov r8d, ecx
    mov r9, rdi
    mov edi, [root]
    mov esi, [atoms+AT_CLIENTS*4]
    mov edx, 33
    mov ecx, 32
    jmp set_prop

intern_all:
    push rbx
    push r12
    push r13
    lea rbx, [atom_names]
    xor r12d, r12d
.n: cmp byte [rbx], 0
    je .o
    xor ecx, ecx
.l: cmp byte [rbx+rcx], 0
    je .e
    inc ecx
    jmp .l
.e: mov r13d, ecx
    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 16
    mov [rdi+4], r13w
    lea eax, [r13+3]
    shr eax, 2
    add eax, 2
    mov [rdi+2], ax
    lea edx, [rax*4]
    push rdx
    lea rdi, [req+8]
    mov rsi, rbx
    mov ecx, r13d
    rep movsb
    lea rsi, [req]
    pop rdx
    call send
    mov rdi, [fd]
    lea rsi, [ev]
    mov edx, 32
    call read_exact
    test rax, rax
    jnz fail_read
    mov eax, [ev+8]
    lea rdx, [atoms]
    mov [rdx+r12*4], eax
    inc r12d
    lea rbx, [rbx+r13+1]
    jmp .n
.o: pop r13
    pop r12
    pop rbx
    ret

ewmh_init:

    lea rdi, [req]
    xor eax, eax
    mov ecx, 8
    rep stosq
    lea rdi, [req]
    mov byte [rdi], 1
    mov word [rdi+2], 8
    mov eax, [rid_base]
    or eax, 1
    mov [wmcheck], eax
    mov [rdi+4], eax
    mov eax, [root]
    mov [rdi+8], eax
    mov word [rdi+16], 1
    mov word [rdi+18], 1
    mov word [rdi+22], 2
    mov rsi, rdi
    mov edx, 32
    call send

    mov edi, [root]
    mov esi, [atoms+AT_CHECK*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [wmcheck]
    call set_prop
    mov edi, [wmcheck]
    mov esi, [atoms+AT_CHECK*4]
    mov edx, 33
    mov ecx, 32
    mov r8d, 1
    lea r9, [wmcheck]
    call set_prop
    mov edi, [wmcheck]
    mov esi, [atoms+AT_WMNAME*4]
    mov edx, [atoms+AT_UTF8*4]
    mov ecx, 8
    mov r8d, WM_NAME_LEN
    lea r9, [wm_name]
    call set_prop

    mov edi, [root]
    mov esi, [atoms+AT_SUPPORTED*4]
    mov edx, 4
    mov ecx, 32
    mov r8d, 15
    lea r9, [atoms+AT_CHECK*4]
    call set_prop

    mov edi, [root]
    mov esi, [atoms+AT_NDESK*4]
    mov edx, 6
    mov ecx, 32
    mov r8d, 1
    lea r9, [ntags]
    call set_prop
    call ewmh_desktop
    call ewmh_clients
    jmp ewmh_active
