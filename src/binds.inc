    exec 36, MODK, "ghostty"
    bind 24, MODK, A_CLOSE
    bind 44, MODK, A_NEXT
    bind 45, MODK, A_PREV
    bind 43, MODK, A_SHRINK
    bind 46, MODK, A_GROW
    bind 65, MODK, A_FLIP
    exec 40, MODK, "dmenu_run"
    bind 21, MODK, A_BALANCE
    bind 44, MODK|SHIFT, A_SWAPN
    bind 45, MODK|SHIFT, A_SWAPP
    bind 26, MODK|SHIFT, A_QUIT
    bind 24, MODK|SHIFT, A_KILL
    bind 41, MODK, A_FULL
    exec 39, MODK, "scrot ~/Pictures/%Y-%m-%d_%H%M%S.png"
    exec 123, 0, "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
    exec 122, 0, "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    exec 121, 0, "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    tagkeys 10, MODK, MODK|SHIFT
