## Bare-bones SDL2 example
import std/random
import ca
import ca/neighborhoods

randomize()

type MyCell = ref object of Cell
  isAlive*: bool

let
  Alive = MyCell(isAlive: true)
  Dead = MyCell(isAlive: false)

proc `init.dead`(meta: Metadata): Cell = Dead

proc `init.grid`(x, y: int; thickness: int; active: Init; disactive: Init = `init.dead`): Init =
  proc(meta: Metadata): Cell =
    if meta.x mod (x + thickness) < x and
       meta.y mod (x + thickness) < y:
      active(meta)
    else:
      disactive(meta)

proc `init.rand`(ratio: float): Init =
  proc(meta: Metadata): Cell =
    if rand(1.0) >= ratio: Alive
    else: Dead

method draw(cell: MyCell): Color =
  if cell == Alive: White
  else: Transparent

method next(cell: MyCell; field: Field; meta: Metadata): Cell =
  var alives: int
  for (dx, dy) in neighborhoods.Moore:
    var other = MyCell field.delta(meta, dx, dy)
    if other == Alive:
      inc alives

  if cell == Alive:
    case alives
    of 0, 1:
      Dead
    of 2, 3:
      Alive
    else:
      Dead
  else:
    if alives == 3:
      Alive
    else:
      Dead

var
  field = field("Game of Life", 64, 64,
    init= `init.grid`(14, 14, 8, `init.rand`(ratio= 0.6)))
simulate field