```
Usage: bash chooser.sh [choices...]
    
# Use k and j to go up and down
# Press Enter to choose

bash choorser.sh $(ls -a)
 README.md
█chooser.sh
 .git

# choose from stdin using `-`
seq 1 5 | bash chooser.sh -
 1
 2
 3
█4
 5

# storing the output
choice=$(bash chooser.sh 1 2 3)
```

### Resources
 - https://espterm.github.io/docs/VT100%20escape%20codes.html
 - https://github.com/wick3dr0se/bashin/blob/main/lib/std/ansi.sh
 - https://github.com/wick3dr0se/bashin/blob/main/lib/std/tui.sh
 - https://github.com/wick3dr0se/fml/blob/main/fml
 - https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
 - https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
 - https://stackoverflow.com/questions/2612274/bash-shell-scripting-detect-the-enter-key
