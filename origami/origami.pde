// Thanks to: Sarah Armstrong

static final int N = 99;
static final int RAND = 20;

int[] xs;
int[] ys;
int[] cs;

void setup() {
  size(800, 500);
  xs = new int[N];
  ys = new int[N];
  cs = new int[N];
  for (int i = 0; i < N; i ++) {
    xs[i] = round(i * 5 + 200);
    ys[i] = (round(600 - i * 40) + 100 * height) % height;
    cs[i] = color(i * 2, i + 200, 250 - i * 2.5);
  }
  stroke(0);
  strokeWeight(3);
}

int ii = 0;
void draw() {
  fill(0, 0, 0, 7);
  rect(0, 0, width, height);
  for (int i = 0; i < 3; i ++) {
    ii = (ii + 1) % N;
    xs[ii] += random(RAND) - RAND / 2;
    ys[ii] += random(RAND) - RAND / 2;
    boop(xs[ii], ys[ii], cs[ii]);
  }
}

void boop(int x, int y, int c) {
  fill(c);
  pushMatrix();
  translate(x, y);
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < 15; i ++) {
    vertex(random(100), random(100));
  }
  endShape(CLOSE);
  popMatrix();
}
