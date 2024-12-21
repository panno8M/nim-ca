## Bare-bones SDL2 example
import std/random
import ca

randomize()

type MyCell = ref object of Cell
  meta: Metadata

proc `init.fill`(meta: Metadata): Cell =
  MyCell(meta: meta)

method draw(cell: MyCell): Color =
  (uint8 255-128 + cell.meta.x.succ*2, uint8 255-128 + cell.meta.y.succ*2, 100, 255)

method next(cell: MyCell; field: Field; meta: Metadata): Cell = cell

var
  field = field("Game of Life", 64, 64,
    init= `init.fill`)
simulate field