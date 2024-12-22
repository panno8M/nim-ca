const VonNeumann*: array[4, tuple[dx, dy: int]] = [
            ( 0, -1),
  (-1,  0),           ( 1,  0),
            ( 0,  1),         ]

const Moore*: array[8, tuple[dx, dy: int]] = [
  (-1, -1), ( 0, -1), ( 1, -1),
  (-1,  0),           ( 1,  0),
  (-1,  1), ( 0,  1), ( 1,  1)]

const Hex*: array[6, tuple[dx, dy: int]] = [
       ( 0, -1), ( 1, -1),
  (-1,  0),           ( 1,  0),
       (-1,  1), ( 0,  1), ]