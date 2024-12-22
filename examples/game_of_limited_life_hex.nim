## Bare-bones SDL2 example
import std/[random, sequtils]
import ca
import ca/neighborhoods
import ca/colormixer

randomize()

type MyCell = ref object of Cell
  age*: int

proc `init.rand`(ratio: float): Init =
  proc(meta: Metadata): Cell =
    if rand(1.0) >= ratio: MyCell(age: 1)
    else: MyCell(age: 0)

method draw(cell: MyCell): Color =
  let grad {.global.} = gradient(
    (0.0, colors.Black),
    (0.5, colors.White),
    (1.0, colors.Black),
  )
  grad.lerp(cell.age.min(16)/16)

method next(cell: MyCell; field: Field; meta: Metadata): Cell =
  if cell.age == 16:
    cell.age = 0
    return cell
  let alives = neighborhoods.Hex
    .mapIt(MyCell field.delta(meta, it.dx, it.dy))
    .filterIt(it.age > 0 )
    .len

  if cell.age > 0:
    case alives
    of 3, 4:
      inc cell.age
    else:
      cell.age = 0
  else:
    case alives
    of  2, 3:
      inc cell.age
    else:
      cell.age = 0
  cell

var
  field = field("Game of Limited Life (HEX)", 64, 64,
    init= `init.rand`(ratio= 0.6))
field.cellShape = Hex
simulate field