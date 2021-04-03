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
    scale(width, height * TEXT_BOX_H);
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
  drawTopBar();
  pushMatrix();
    translate(0, TEXT_BOX_H * height);
    fill(0);
    rect(0, 0, width, height * (1f - TEXT_BOX_H));
    fill(130, 140, 150);
    rect(0, 0, width, 41);
    fill(45, 66, 81);
    rect(0, 150, width, 4);
    fill(18, 37, 54);
    rect(0, 154, width, 100);
    pushMatrix();
      translate(0, 154);
      drawBottomBar(height * (1f - TEXT_BOX_H) - 154f);
    popMatrix();
  popMatrix();
}

void drawBottomBar(float _height) {
  fill(45, 66, 81);
  rect(65, 0, 150, _height - 4);
  fill(31, 50, 65);
  rect(218, 0, 134, _height - 4);
}

void drawTopBar() {
  fill(255);
  ellipse(88, 40, 46, 46);
  fill(168, 173, 178);
  ellipse(148, 40, 46, 46);
  ellipse(881, 40, 46, 46);
  stroke(58, 80, 94);
  noFill();
  rect(920, 17, 90, 46);
  fill(255);
  // textFont("arial", 18);
  // textSize(18);
  // text("Java", 940, 42);
  fill(224, 255, 253);
  noStroke();
  rect(65, 80, 100, 42);
  fill(45, 66, 81);
  rect(165, 80, 33, 42);
  fill(255);
  rect(65, 122, 945, height * TEXT_BOX_H);
}

class TextBox {
  Line[] lines;
  int viewport_line = 0;
  int sel_start_line = 0;
  int sel_start_char = 0;
  boolean sel_multi = false;
  int sel_end_line;
  int sel_end_char;
  float cursor_phase = 0f;

  class Line {
    Span root;

    class Span {
      color c = null;
      boolean bold = false;
      String text;

      Span prev = null;
      Span next = null;

      Span splitAt(int x) {
        assert c == null;
        String left = text.substring(0, x);
        String right = text.substring(x);
        text = left;
        Span newSpan = new Span();
        newSpan.text = right;
        newSpan.prev = this;
        newSpan.next = next;
        next = newSpan;
        if (next != null) {
          next.prev = newSpan;
        }
        return newSpan;
      }
    }

    Line(String line_raw) {
      root = Span();
      root.text = line_raw;

      identifyStrings();
      colorize("static",  51, 153, 126);
      colorize("final",   51, 153, 126);
      colorize("float",   226, 102, 26);
      colorize("int",     226, 102, 26);
    }

    void identifyStrings() {
      Span cursor = root;
      int pos;
      Span willDo;
      while (true) {
        pos = cursor.text.indexOf(char(34));
        if (pos == -1) {
          break;
        }
        cursor = cursor.splitAt(pos);

        pos = cursor.text.indexOf(char(34));
        assert pos != -1;
        willDo = cursor.splitAt(pos);
        cursor.c = color(125, 71, 147);
        cursor = willDo;
      }
    }

    void colorize(String keyword, int r, int g, int b) {

    }
  }

  TextBox(String src) {
    String[] lines_raw = splitTokens(src, "\n");
    int n_lines = lines_raw.length;
    lines = new Line[n_lines];
    for (int i = 0; i < n_lines; i ++) {
      lines[i] = new Line(lines_raw[i]);
    }
  }
}
