/*
 *  Vigenere cipher in assembly language
 *  Author: Mihaly Meszaros
 *  <neptun_id_redacted>
 *  University of Szeged
 */

.intel_syntax noprefix
.data 
    res: .byte 0x0
.global vigenere_encrypt
.text
# If the parameter in ebp + 8 is a lowercase character,
# convert it to uppercase by subtracting 0x20 from it
# otherwise return it as-is
to_uppercase:
    push    ebp
	mov     ebp, esp
    mov     eax, DWORD PTR[ebp + 0x8]
    mov     BYTE PTR[ebp + 0x8], al
    cmp     BYTE PTR[ebp + 0x8], 0x60
    jle     _copy_and_return
    cmp     BYTE PTR[ebp + 0x8], 0x7a
    jg      _copy_and_return
    movzx   eax, BYTE PTR[ebp + 0x8]
    sub     eax, 0x20
    jmp     _no_modification
_copy_and_return:
    movzx   eax, BYTE PTR[ebp + 0x8]
_no_modification:
    mov     esp, ebp
	pop     ebp
    ret

is_uppercase:
    push    ebp
	mov     ebp, esp
    mov     eax, DWORD PTR[ebp + 0x8]
    mov     BYTE PTR[ebp + 0x8], al
    cmp     BYTE PTR[ebp + 0x8], 0x40
    jle     _not_uppercase
    cmp     BYTE PTR[ebp + 0x8], 0x5a
    jg      _not_uppercase
    mov     eax, 1
    jmp     _done
_not_uppercase:
    xor     eax, eax
_done:    
    mov     esp, ebp
	pop     ebp
    ret

# [ebp + 0x8]     input
# [ebp + 0xc]     key
# [ebp + 0x10]    output
vigenere_encrypt:
    push    ebp
	mov     ebp, esp
# Return if any of the parameters is null
    cmp     DWORD PTR[ebp + 0x8], 0x0
    je      _end
    cmp     DWORD PTR[ebp + 0xc], 0x0
    je      _end
    cmp     DWORD PTR[ebp + 0x10], 0x0
    je      _end
    mov     edx, DWORD PTR[ebp + 0x8]   # Move the first param to EDX
    mov     eax, DWORD PTR[ebp + 0xc]   # Move the second param to EAX
    xor     edi, edi                    # i = 0
_loop:
# Stop at \0 null terminator character
    cmp     BYTE PTR[edx + edi], 0x00   # while(input[i] != 0) ...
    je      _end
# [edx + edi]  =   input[i]
# [eax + edi]  =   key[i]
#  edi         =   i
    push    eax                         # EAX stores the pointer to char* key
    push    ebx                         # Pushing this would save us from segfaulting
    push    edx                         # EDX stores the pointer to char* input
    movzx   edx, BYTE PTR[edx + edi]    # Move the current character of input[i] to EDX
    movzx   ebx, BYTE PTR[eax + edi]    # Move the current character of key[i] to EBX
    push    edx
    call    is_uppercase
    mov     BYTE PTR[res], al           # save the result of is_uppercase to res
    add     esp, 0x4
    push    edx
    call    to_uppercase
    add     esp, 0x4
    mov     edx, eax                    # edx = to_uppercase(edx)
    push    ebx
    call    to_uppercase
    add     esp, 0x4
    mov     ebx, eax                    # ebx = to_uppercase(ebx)
    add     bl, dl                      # bl = input[i] + key[i]
    xor     edx, edx
    mov     eax, ebx
    mov     ebx, 0x1a                   # divisor = 26
    div     ebx                         # edx = bl % 26
    test    BYTE PTR[res], 0x0
    jz      _lostr                      # ZF = 1 if input[i] was lowercase
    add     edx, 0x41                   # input was not uppercase => convert it to lowercase
    jmp     _skip
_lostr:
    add     edx, 0x61
_skip:      
    mov     ecx, [ebp + 0x10]           # acquire a pointer to char* output
    mov     DWORD PTR[ecx + edi], edx   # output[i] = edx
    pop     edx                         # Restore pointer char* input
    pop     ebx                         # Leaving EBX dirty will segfault
    pop     eax                         # Restore pointer char* key
    inc     edi                         # i++
    jmp     _loop
_end:
    xor     eax, eax                    # Return value is always 0
    mov     esp, ebp
	pop     ebp
	ret
