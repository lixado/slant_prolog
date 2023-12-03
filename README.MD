# Slant Solver in Prolog

## Introduction

This Prolog program is designed to solve slant puzzles provided in a text file format. The input file should follow a specific structure to ensure accurate processing by the solver.

## Input Format

The input file, named `puzzle_unsolved.txt`, should have the following structure:

1. **Number of Puzzles:** Specifies the total number of puzzles in the file. This information is provided on the first line.

2. **Puzzle Size:** Each puzzle is defined by its size, indicating width and height. This information is presented in the format `size#x#`, where # represents the respective width and height.

3. **Puzzle Grid:** Following the size specification, the puzzle grid is presented with the actual puzzle elements. The grid consists of cells denoted by underscores, numbers, or other characters that represent puzzle elements.

## Example

Here is an example of a valid `puzzle_unsolved.txt` file with two puzzles:

```
puzzles 2
size 3x3
_ 0 _ _
 x x x 
_ _ _ 2
 x x x 
_ _ 3 _
 x x x 
_ 2 _ _
size 3x4
_ 2 1 _
 x x x 
_ 2 _ _
 x x x 
_ _ _ 1
 x x x 
_ _ 1 2
 x x x 
1 _ 1 _
```

### Solved puzzle example (3x3)
```
_ 0 _ _
 \ / \ 
_ _ _ 2
 / \ / 
_ _ 3 _
 \ / / 
_ 2 _ _
```

## Prolog solver explanation (main.pro)

### Input reading
```
[ [ [3,3],
    ['_','0','_','_'],
    [x,x,x],
    ['_','_','_','2'],
    [x,x,x],
    ['_','_','3','_'],
    [x,x,x],
    ['_','2','_','_']
  ],
  [ [3,3],
    ['_','0','2','_'],
    [x,x,x],
    ['1','_','_','_'],
    [x,x,x],
    ['_','3','_','1'],
    [x,x,x],
    ['_','_','2','_']
  ]
]
```

### Nodes data scruture =  [Upleft slant, Upright slant, Bot left slant, Bot right slant, Square value]
```
[ [ ['','','',x,'_'],
    ['','',x,x,'0'],
    ['','',x,x,'_'],
    ['','',x,'','_'],
    ['',x,'',x,'_'],
    [x,x,x,x,'_'],
    [x,x,x,x,'_'],
    [x,'',x,'','2'],
    ['',x,'',x,'_'],
    [x,x,x,x,'_'],
    [x,x,x,x,'3'],
    [x,'',x,'','_'],
    ['',x,'','','_'],
    [x,x,'','','2'],
    [x,x,'','','_'],
    [x,'','','','_']
  ],
  [ ['','','',x,'_'],
    ['','',x,x,'0'],
    ['','',x,x,'2'],
    ['','',x,'','_'],
    ['',x,'',x,'1'],
    [x,x,x,x,'_'],
    [x,x,x,x,'_'],
    [x,'',x,'','_'],
    ['',x,'',x,'_'],
    [x,x,x,x,'3'],
    [x,x,x,x,'_'],
    [x,'',x,'','1'],
    ['',x,'','','_'],
    [x,x,'','','_'],
    [x,x,'','','2'],
    [x,'','','','_']
  ]
]
```

### Static solve nodes using pattern matching

Simple example, if any 4 is in the game fill the slants around it pointing towards it
```
solve_node([_, _, _, _, '4'], ['\\', '/', '//', '\\', '4']).
```