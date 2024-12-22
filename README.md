# nim-ca

Simple Cellular-automata simulation library & engine.

## What is it?

This tool allows you to execute a cellular automaton by simply defining three functions: an initialization function, a transition function, and a drawing function.

The basic colors, their blending functions, gradients, neighborhood indexes, switching between rect and hex views, and other things you might want to implement a cellular automaton are already defined.

If you are interested, please open and look at [game_of_life.nim][1] first. You will see that only the rules of the cellular automaton are described, and conversely, everything else is hidden.

## Dependencies

* [nim-lang/nim][2] >= 2.0.0
* [nim-lang/sdl2][3] >= 2.0.5 (via nimble)
* [libsdl-org/SDL][4] >= 2.30.10
* [giroletm/SDL2_gfx][5] >= 1.0.4

## Examples

### [Game of Life](examples/game_of_life.nim) >>

![image](images/Peek%202024-12-22%2022-19.gif)

### [Game of Struggle](examples/game_of_struggle.nim) >>

![image](images/Peek%202024-12-22%2022-18.gif)

### [Game of Limited Life (HEX)](examples/game_of_limited_life_hex.nim) >>

![image](images/Peek%202024-12-22%2022-22.gif)

[1]: examples/game_of_life.nim
[2]: https://github.com/nim-lang/nim
[3]: https://github.com/nim-lang/sdl2
[4]: https://github.com/libsdl-org/SDL
[5]: https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/