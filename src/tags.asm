ctx_save:
    mov eax, [cur]
    lea rdx, [roots]
    mov ecx, [root_node]
    mov [rdx+rax*4], ecx
    lea rdx, [foci]
    mov ecx, [focus]
    mov [rdx+rax*4], ecx
    ret

ctx_load:
    mov [cur], edi
    mov eax, edi
    lea rdx, [roots]
    mov ecx, [rdx+rax*4]
    mov [root_node], ecx
    lea rdx, [foci]
    mov ecx, [rdx+rax*4]
    mov [focus], ecx
    ret

node_tag:
    mov eax, edi
    lea rdx, [nodes]
.u: mov ecx, eax
    shl ecx, 5
    mov esi, [rdx+rcx+N_PAR]
    cmp esi, -1
    je .r
    mov eax, esi
    jmp .u
.r: mov r8d, eax
    call ctx_save
    lea rdx, [roots]
    xor eax, eax
.t: cmp eax, NTAGS
    jge .no
    cmp [rdx+rax*4], r8d
    je .ret
    inc eax
    jmp .t
.no:
    mov eax, -1
.ret:
    ret

remove_any:
    push rbx
    push r12
    mov ebx, edi
    call node_tag
    cmp eax, -1
    je .o
    cmp eax, [cur]
    je .cur
    mov r12d, [cur]
    mov edi, eax
    call ctx_load
    mov byte [quiet], 1
    mov edi, ebx
    call remove_leaf
    mov byte [quiet], 0
    call ctx_save
    mov edi, r12d
    call ctx_load
    jmp .done
.cur:
    mov edi, ebx
    call remove_leaf
    call ewmh_active
.done:
    call ewmh_clients
.o: pop r12
    pop rbx
    ret

unmap_window:
    lea rsi, [req]
    mov byte [rsi], 10
    mov byte [rsi+1], 0
    mov word [rsi+2], 2
    mov [rsi+4], edi
    mov edx, 8
    jmp send

tag_visit:
    cmp edi, -1
    je .r
    push rbx
    push r12
    mov ebx, edi
    mov r12d, esi
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    cmp dword [rdx+rax+N_WIN], 0
    je .int
    mov edi, [rdx+rax+N_WIN]
    test r12d, r12d
    jz .hide
    call map_window
    jmp .o
.hide:
    inc byte [rdx+rax+N_FLG]
    call unmap_window
    jmp .o
.int:
    mov edi, [rdx+rax+N_L]
    mov esi, r12d
    call tag_visit
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov edi, [rdx+rax+N_R]
    mov esi, r12d
    call tag_visit
.o: pop r12
    pop rbx
.r: ret

float_visit:
    push rbx
    push r12
    push r13
    mov r12d, edi
    mov r13d, esi
    xor ebx, ebx
.l: cmp ebx, FLN
    jge .o
    lea rdx, [flt]
    mov eax, ebx
    shl eax, 4
    cmp dword [rdx+rax], 0
    je .n
    cmp [rdx+rax+4], r12d
    jne .n
    mov edi, [rdx+rax]
    test r13d, r13d
    jz .h
    call map_window
    jmp .n
.h: inc dword [rdx+rax+8]
    call unmap_window
.n: inc ebx
    jmp .l
.o: pop r13
    pop r12
    pop rbx
    ret

switch_tag:
    push rbx
    mov ebx, edi
    cmp ebx, NTAGS
    jae .r
    cmp ebx, [cur]
    je .r
    call ctx_save
    mov edi, [root_node]
    xor esi, esi
    call tag_visit
    mov edi, [cur]
    xor esi, esi
    call float_visit
    mov edi, ebx
    call ctx_load
    mov edi, [root_node]
    mov esi, 1
    call tag_visit
    mov edi, [cur]
    mov esi, 1
    call float_visit
    call relayout
    mov dword [fwin], 0
    mov edi, [focus]
    cmp edi, -1
    je .nof
    call set_focus
    jmp .done
.nof:
    mov edi, 1
    call send_focus
    call ewmh_active
.done:
    call ewmh_desktop
.r: pop rbx
    ret

move_to_tag:
    push rbx
    push r12
    push r13
    mov r12d, edi
    cmp r12d, NTAGS
    jae .o
    cmp r12d, [cur]
    je .o
    mov edi, [fwin]
    test edi, edi
    jz .tiled
    call fl_find
    cmp eax, -1
    je .tiled
    lea rdx, [flt]
    shl eax, 4
    mov [rdx+rax+4], r12d
    inc dword [rdx+rax+8]
    mov edi, [fwin]
    mov esi, COL_UNFOC
    call send_border
    mov edi, [fwin]
    call unmap_window
    mov dword [fwin], 0
    mov edi, [focus]
    cmp edi, -1
    je .fnof
    call set_focus
    jmp .o
.fnof:
    mov edi, 1
    call send_focus
    call ewmh_active
    jmp .o
.tiled:
    mov ebx, [focus]
    cmp ebx, -1
    je .o
    lea rdx, [nodes]
    mov eax, ebx
    shl eax, 5
    mov r13d, [rdx+rax+N_WIN]
    test r13d, r13d
    jz .o
    test dword [rdx+rax+N_FLG], FL_FS
    jz .nf
    mov edi, ebx
    xor esi, esi
    call set_fs
.nf:
    mov edi, ebx
    call remove_leaf
    mov ebx, [cur]
    call ctx_save
    mov edi, r12d
    call ctx_load
    mov byte [quiet], 1
    mov edi, r13d
    call add_window
    mov byte [quiet], 0
    call ctx_save
    mov edi, ebx
    call ctx_load
    call ewmh_clients
    call ewmh_active
.o: pop r13
    pop r12
    pop rbx
    ret

show_all:
    lea rdx, [nodes]
    xor ecx, ecx
.n: cmp ecx, MAXN
    jge .f
    mov eax, ecx
    shl eax, 5
    cmp dword [rdx+rax+N_USED], 0
    je .nx
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nx
    push rcx
    call map_window
    pop rcx
    lea rdx, [nodes]
.nx:inc ecx
    jmp .n
.f: xor ecx, ecx
.g: cmp ecx, FLN
    jge .r
    lea rdx, [flt]
    mov eax, ecx
    shl eax, 4
    mov edi, [rdx+rax]
    test edi, edi
    jz .gx
    push rcx
    call map_window
    pop rcx
.gx:inc ecx
    jmp .g
.r: ret
