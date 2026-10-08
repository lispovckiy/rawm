%assign KEYS_N 0

%macro bind 3
    db %1, %2, %3
    %assign KEYS_N KEYS_N+1
%endmacro

%macro exec 3
    db %1, %2, A_CMD, %3, 0
    %assign KEYS_N KEYS_N+1
%endmacro

%macro tagkeys 3
    %assign kt 0
    %rep NTAGS
        db %1+kt, %2, A_TAG+kt
        db %1+kt, %3, A_MOVE+kt
        %assign KEYS_N KEYS_N+2
        %assign kt kt+1
    %endrep
%endmacro

keytab:
%include "src/binds.inc"
