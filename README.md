# ComputerCraft TNT Placer

A sophisticated ComputerCraft turtle program for safely placing and detonating TNT in a 3D pattern. This program allows for precise TNT placement with automated return-to-home functionality.

https://bubnugs-coding.github.io/ComputerCraft-TNT-Placer

## Features

- Places TNT in a 3D cross pattern (4 TNT blocks per layer)
- Automatically calculates and creates multiple layers if needed
- Smart pathfinding and obstacle clearing
- Fuel management system
- Safe detonation using redstone block
- Automatic return to starting position
- Built-in safety confirmations
- Detailed progress reporting

## Requirements

- ComputerCraft Mining Turtle
- TNT blocks
- Redstone block
- Fuel (coal, charcoal, etc.)

## Installation

1. Create a new file on your turtle named `TNTPlacer.lua`
2. Copy the contents of `TNTPlacer.lua` into the file
3. Save the file

## Usage

1. Place required items in the turtle's inventory:
   - TNT blocks
   - 1 redstone block
   - Fuel

2. Run the program:
```lua
TNTPlacer
```

3. Enter the requested information:
   - Current coordinates (X, Y, Z)
   - Current facing direction (0=North, 1=East, 2=South, 3=West)
   - Target coordinates (X, Y, Z)
   - Number of TNT blocks to place

4. Type 'CONFIRM' when prompted to begin the operation

## TNT Placement Pattern

The program places TNT in the following pattern: 
