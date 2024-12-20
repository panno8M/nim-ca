## Bare-bones SDL2 example
import std/random
import ca

randomize()

type
  Team {.pure.} = enum
    Red
    Blue
    Dead
  MyCell = ref object of Cell
    team*: Team

let
  Red = MyCell(team: Red)
  Blue = MyCell(team: Blue)
  Dead = MyCell(team: Dead)

proc `init.rand`(ratioRed, ratioBlue: float): Init =
  proc(meta: Metadata): Cell =
    var ratio = rand(1.0)
    if ratio <= ratioRed: Red
    elif ratio <= ratioRed + ratioBlue: Blue
    else: Dead

method draw(cell: MyCell): Color =
  if cell == Red: colors.Coral
  elif cell == Blue: colors.Skyblue
  else: Blank

method next(cell: MyCell; field: Field; meta: Metadata): Cell =
  discard
  const neighbordelta: array[8, tuple[dx, dy: int]] = [
    (-1, -1), ( 0, -1), ( 1, -1),
    (-1,  0),           ( 1,  0),
    (-1,  1), ( 0,  1), ( 1,  1)]
  var balance: range[-8..8]
  for (dx, dy) in neighbordelta:
    var other = MyCell field.delta(meta, dx, dy)
    if other == Red:
      inc balance
    elif other == Blue:
      dec balance

  case balance
  of -8 .. -4: # overpopulation
    Dead
  of -3: # living
    Blue
  of -2:
    if cell == Blue: # living
      Blue
    else:
      Dead
  of -1 .. 1:
    Dead
  of 2:
    if cell == Red: # living
      Red
    else:
      Dead
  of 3:
    Red
  of 4 .. 8: # overpopulation
    Dead

var
  field = field("Game of Life", 64, 64,
    init= `init.rand`(ratioRed= 0.5, ratioBlue = 0.5),
    clear= Gray)
simulate field