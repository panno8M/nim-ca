import std/algorithm
import sdl2

type
  GradientJoint* = tuple
    pos: float
    color: Color
  Gradient* = object
    joints*: seq[GradientJoint]

proc lerp*(a, b: Color; factor: float): Color =
  (
    uint8(a.r.float * (1-factor) + b.r.float * (factor)),
    uint8(a.g.float * (1-factor) + b.g.float * (factor)),
    uint8(a.b.float * (1-factor) + b.b.float * (factor)),
    uint8(a.a.float * (1-factor) + b.a.float * (factor)),
  )

proc cmp*(a, b: GradientJoint): int = cmp a.pos, b.pos

proc gradient*(joints: varargs[GradientJoint]): Gradient =
  Gradient(joints: (@joints).sorted(cmp))

proc lerp*(grad: Gradient; factor: float): Color =
  if grad.joints.len == 0:
    return
  if factor <= grad.joints[0].pos:
    return grad.joints[0].color
  if factor >= grad.joints[^1].pos:
    return grad.joints[^1].color

  for i, joint in grad.joints:
    if factor == joint.pos:
      return joint.color
    if factor < joint.pos:
      let prev = grad.joints[i.pred]
      return lerp(prev.color, joint.color, (factor - prev.pos) / (joint.pos - prev.pos))