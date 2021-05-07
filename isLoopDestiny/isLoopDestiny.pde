static final float DT = .1f;

float t = 0f;
PVector last_p = new PVector(0, 0);
PVector last_n = new PVector(0, 0);

void setup() {
  size(1000, 1000);
  background(0);
  stroke(255);
}

void draw() {
  translate(width / 2, height / 2);
  t += DT;
  PVector p = pos( t);
  PVector n = pos(-t);
  line(last_p.x, last_p.y, p.x, p.y);
  line(last_n.x, last_n.y, n.x, n.y);
  last_p = p;
  last_n = n;
}

float r(float t) {
  return atan(t * .1) * width * .3;
}

float theta(float t) {
  return cos(t);
}

PVector pos(float t) {
  float _theta = theta(t);
  float _r = r(t);
  return new PVector(cos(_theta) * _r, sin(_theta) * _r);
}
