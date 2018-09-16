TALL = 5
all = []
TEXTSIZE = 18
TEXTWIDTH = 36
TEXTHEIGHT = 30
ROTATE = -.25
DEPTH = 24
done = False
ROTATE_GROWTH = 1.028
HEIGHT_GROWTH = 1.025
LINEWIDTH = 2

def setup():
  global DEPTH
  size(1300, 700)
  textSize(TEXTSIZE)
  strokeWeight(LINEWIDTH)
  textAlign(CENTER)
  fill(0)
  DEPTH = 1
  frameRate(4)

def draw():
  global done, DEPTH, all
  background(255)
  pushMatrix()
  translate(width*.8, height*.6)
  f(1, 0)
  popMatrix()
  DEPTH += 1
  all = []

def f(start, depth):
  if depth == DEPTH:
    return
  depth_height = TEXTHEIGHT * HEIGHT_GROWTH**depth
  stem = []
  drawing = start
  stroke(0, 0, 255)
  for i in range(TALL):
    text(str(drawing), -TEXTWIDTH, -(i+1) * depth_height, TEXTWIDTH, TEXTHEIGHT)
    line(0, -i * depth_height, 0, -i * depth_height - TEXTHEIGHT)
    stem.append(drawing)
    all.append(drawing)
    drawing *= 2
  if depth==0:
    noStroke()
    rect(-TEXTWIDTH, -depth_height*1.1, TEXTWIDTH, TEXTHEIGHT)
    strokeWeight(LINEWIDTH)
    fill(255)
    text('1', -TEXTWIDTH, -depth_height, TEXTWIDTH, TEXTHEIGHT)
    fill(0)
  translate(-TEXTWIDTH, -depth_height * (len(stem)-.4))
  rotated = 0
  for i in reversed(stem):
    if (i-1) % 3 == 0:
      child = (i-1) / 3
      if child % 2 == 1:
        stroke(255, 0, 0)
        line(-TEXTWIDTH/6, 0, TEXTWIDTH/6, 0)
        if child in all:
          text(str(child), -TEXTWIDTH, -TEXTHEIGHT*.4, TEXTWIDTH, TEXTHEIGHT)
        else:
          pushMatrix()
          translate(-.5*TEXTWIDTH, 0)
          rotated += 1
          rotate(ROTATE * rotated * ROTATE_GROWTH**depth)
          translate(.5*TEXTWIDTH, .6*TEXTHEIGHT)
          f(child, depth + 1)
          popMatrix()
    translate(0, depth_height)
