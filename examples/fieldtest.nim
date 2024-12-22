## Bare-bones SDL2 example
import std/random
import ca
import ca/colormixer

randomize()

type MyCell = ref object of Cell
  meta: Metadata

proc `init.fill`(meta: Metadata): Cell =
  MyCell(meta: meta)

method draw(cell: MyCell): Color =
  let grad1 {.global.} = gradient(
    (0.0, colors.Red),
    (0.5, colors.Green),
    (1.0, colors.Blue))
  let grad2 {.global.} = gradient(
    (0.0, colors.Black),
    (1.0, colors.White))
  lerp(
    grad1.lerp(cell.meta.x/63),
    grad2.lerp(cell.meta.y/63),
    0.3)

method next(cell: MyCell; field: Field; meta: Metadata): Cell = cell

var
  field = field("Game of Life", 64, 64,
    init= `init.fill`)
simulate field