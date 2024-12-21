import std/[os, math]
import sdl2
import sdl2/gfx
import ca/colors

type
  Init* = proc(meta: Metadata): Cell
  Cell* = ref object of RootObj
  CellShape* = enum
    Rect, Hex

  Metadata* = object
    x*, y*: Natural

  Field* = ref object
    init*: Init
    width*, height*: int
    scale*: int = 10
    cellShape*: CellShape = Rect
    clearColor*: Color
    title*: string
    current*: seq[seq[Cell]]
    next*: seq[seq[Cell]]

export sdl2.Color
export colors

const Transparent*: Color = (0, 0, 0, 0)

proc hexagon(x, y, radius: int16): tuple[x, y: array[6, int16]] =
  let radius = float radius
  const r3 = sqrt(3f)
  const HexagonX = [ 0.0, r3/2, r3/2, 0, -r3/2, -r3/2]
  const HexagonY = [-1.0, -1/2,  1/2, 1,   1/2,  -1/2]
  for i, dx in HexagonX:
    result.x[i] = int16(dx * radius) + x
  for i, dy in HexagonY:
    result.y[i] = int16(dy * radius) + y

proc fillHexagon(renderer: RendererPtr; x, y, radius: int16; color: Color) =
  let (hx, hy) = hexagon(x, y, radius)
  discard renderer.filledPolygonRGBA(addr hx[0], addr hy[0], 6, color.r, color.g, color.b, color.a)

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
  let s = field.scale
  for x, y, cell in field.mcells:
    let color = cell.draw
    if color == Transparent: continue
    if field.cellShape == Rect:
      renderer.setDrawColor color
      var rect = rect(cint x*s, cint y*s, cint s, cint s)
      renderer.fillRect rect
    else:
      let (fx, fy, fs) = (float x, float y, float s)
      let hx = int16(fs * (fx + fy/2)) mod int16 (field.width * s)
      let hy = int16(fy * 0.8 * fs)
      renderer.fillHexagon(hx, hy, int16(fs/2), color)
      if hx == 0:
        renderer.fillHexagon(int16(field.width * s), hy, int16(fs/2), color)
      if hy == 0:
        renderer.fillHexagon(hx, int16(field.height.float * 0.8 * fs), int16(fs/2), color)
      if hx == 0 and hy == 0:
        renderer.fillHexagon(int16(field.width * s), int16(field.height.float * 0.8 * fs), int16(fs/2), color)


proc update*(field: Field) =
  for y in 0..field.next.high:
    for x in 0..field.next[y].high:
      let meta = Metadata(x: x, y: y)
      field.next[y][x] = field.current[y][x].next(field, meta)
  field.current = field.next

proc createWindow*(field: Field; title: string): WindowPtr =
  if field.cellShape == Rect:
    createWindow(title, 100, 100,
      cint field.width*field.scale,
      cint field.height*field.scale,
      SDL_WINDOW_SHOWN)
  else:
    createWindow(title, 100, 100,
      cint field.width*field.scale,
      cint float(field.height*field.scale) * 0.8,
      SDL_WINDOW_SHOWN)

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