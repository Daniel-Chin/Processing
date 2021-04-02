static final float TEXT_BOX_H = .75f;
static final int[] C_TOP = {20, 42, 62};
static final int[] C_MID = {2, 4, 7};
static final float C_SMOOTH = .02;

void setup() {
  size(1030, 810);
}

void draw() {
  drawBack();
}

void drawBack() {
  pushMatrix();
  scale(width, TEXT_BOX_H * height);
  noStroke();
  float j;
  for (float i = 0; i < 1; i += C_SMOOTH) {
    j = 1 - i;
    fill(
      C_MID[0] * i + C_TOP[0] * j,
      C_MID[1] * i + C_TOP[1] * j,
      C_MID[2] * i + C_TOP[2] * j
    );
    rect(0f, i, 1f, C_SMOOTH);
  }
  popMatrix();
}
