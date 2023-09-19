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
