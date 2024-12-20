import std/os
import sdl2
import ca/colors

type
  Init* = proc(meta: Metadata): Cell
  Cell* = ref object of RootObj

  Metadata* = object
    x*, y*: Natural

  Field* = ref object
    init*: Init
    width*, height*: int
    clearColor*: Color
    title*: string
    current*: seq[seq[Cell]]
    next*: seq[seq[Cell]]

export sdl2.Color
export colors

const Blank*: Color = (0, 0, 0, 0)

method draw*(cell: Cell): Color {.base.} = (discard)
method next*(cell: Cell; field: Field; meta: Metadata): Cell {.base.} = (discard)

proc reset(field: Field) =
  for dy in 0..<field.height:
    for dx in 0..<field.width:
      let meta = Metadata(x: dx, y: dy)
      field.current[dy][dx] = field.init meta

proc field*(title: string; width, height: Positive; init: Init; clear: Color = Black): Field =
  new result
  result.title = title
  result.width = width
  result.height = height
  result.init = init
  result.clearColor = clear

  result.current = newSeqOfCap[seq[Cell]](height)
  result.next = newSeqOfCap[seq[Cell]](height)
  for dy in 0..<height:
    result.current.add newSeq[Cell](width)
    result.next.add newSeq[Cell](width)
  reset result

proc delta*(field: Field; meta: Metadata; dx, dy: int): Cell =
  let ny = (meta.y + dy + field.height) mod field.height
  let nx = (meta.x + dx + field.width) mod field.width
  field.current[ny][nx]

iterator mcells*(field: Field): tuple[x, y: int; cell: Cell] =
  for y, row in field.current:
    for x, cell in row:
      yield (x, y, cell)

proc drawField*(renderer: RendererPtr; field: Field) =
  for x, y, cell in field.mcells:
    let color = cell.draw
    if color == Blank: continue
    renderer.setDrawColor color
    var rect = rect(cint x*10, cint y*10, 10, 10)
    renderer.fillRect rect

proc update*(field: Field) =
  for y in 0..field.next.high:
    for x in 0..field.next[y].high:
      let meta = Metadata(x: x, y: y)
      field.next[y][x] = field.current[y][x].next(field, meta)
  field.current = field.next

proc createWindow*(field: Field; title: string): WindowPtr =
  createWindow(title, 100, 100, cint field.width*10 , cint field.height*10, SDL_WINDOW_SHOWN)

proc simulate*(field: Field) =
  discard sdl2.init(INIT_EVERYTHING)
  var
    window: WindowPtr
    render: RendererPtr

  window = field.createWindow(field.title)
  render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)

  var
    evt = sdl2.defaultEvent
    runGame = true

  template quitGame =
    runGame = false
    break

  while runGame:
    while pollEvent(evt):
      case evt.kind
      of QuitEvent:
        quitGame()
      of KeyDown:
        case evt.key.keysym.scancode
        of SDL_SCANCODE_ESCAPE:
          quitGame
        of SDL_SCANCODE_SPACE:
          reset field
        else:
          discard
      else:
        discard

    render.setDrawColor field.clearColor
    render.clear

    update field
    render.drawField field

    render.present
    sleep 100

  destroy render
  destroy window