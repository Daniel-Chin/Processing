static final float TEXT_BOX_H = .75f;
static final int[] C_TOP = {20, 42, 62};
static final int[] C_MID = {2, 4, 7};
static final float C_SMOOTH = .02;

PFont sourceCodePro;

TextBox textBox;

void setup() {
  size(1030, 810);
  sourceCodePro = createFont("sourcecodepro/SourceCodePro-Regular.ttf", TextBox.TEXT_SIZE);
  textBox = new TextBox("static final float TEXT_BOX_H = .75f;\nstatic final int[] C_TOP = {20, 42, 62};\nstatic final int[] C_MID = {2, 4, 7};\nstatic final float C_SMOOTH = .02;");
  noStroke();
  textAlign(LEFT, TOP);
}

void draw() {
  drawBack();
  drawTopBar();
  pushMatrix();
    translate(65, 122);
    textBox.draw();
  popMatrix();
  drawLow();
}

void drawBack() {
  pushMatrix();
    scale(width, height * TEXT_BOX_H);
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

void drawLow() {
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
  noStroke();
  fill(255);
  // textFont("arial", 18);
  // textSize(18);
  // text("Java", 940, 42);
  fill(224, 255, 253);
  rect(65, 80, 100, 42);
  fill(45, 66, 81);
  rect(165, 80, 33, 42);
  fill(255);
  rect(65, 122, 945, height * TEXT_BOX_H);
}

class TextBox {
  static final int VIEWPORT_N_LINES = 13;
  static final int LINE_HEIGHT = 35;
  static final int WIDTH = 934;
  static final int TEXT_SIZE = 27;
  static final int CHAR_WIDTH = TEXT_SIZE;
  static final int CURSOR_BLINK_INTERVAL = 500;

  Line[] lines;
  int viewport_line = 0;
  int sel_start_line = 0;
  int sel_start_char = 0;
  boolean sel_multi = false;
  int sel_end_line;
  int sel_end_char;

  class Line {
    Span root;

    class Span {
      color c = 0;
      boolean bold = false;
      String text;

      Span prev = null;
      Span next = null;

      Span splitAt(int x) {
        assert c == 0;
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
      root = new Span();
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

  void draw() {
    int rel_sel_line = sel_start_line - viewport_line;

    // current line highlight
    if (! sel_multi) {
      fill(235, 255, 253);
      rect(
        0, LINE_HEIGHT * rel_sel_line, 
        WIDTH, LINE_HEIGHT
      );
    }

    // line number highlight
    fill(88, 116, 120);
    rect(
      0, LINE_HEIGHT * rel_sel_line, 
      -100, LINE_HEIGHT
    );

    // line numbers
    fill(187, 214, 213);
    textAlign(RIGHT, TOP);
    textSize(16);
    for (int i = 0; i < VIEWPORT_N_LINES; i ++) {
      text(
        String.valueOf(viewport_line + i + 1), 
        -6, LINE_HEIGHT * i
      );
    }
    textAlign(LEFT, TOP);

    // slight left padding
    pushMatrix();
      translate(6, 0);

      // selection background
      fill(255, 204, 0);
      for (
        int i = sel_start_line; i <= sel_end_line; i ++
      ) {
        if (i == sel_start_line) {
          if (i == sel_end_line) {
            // same line
            rect(
              CHAR_WIDTH * sel_start_char, 
              LINE_HEIGHT * (i - viewport_line), 
              CHAR_WIDTH * (sel_end_char - sel_start_char), 
              LINE_HEIGHT
            );
          } else {
            // just start
            rect(
              CHAR_WIDTH * sel_start_char, 
              LINE_HEIGHT * (i - viewport_line), 
              WIDTH - CHAR_WIDTH * sel_start_char, 
              LINE_HEIGHT
            );
          }
        } else {
          if (i == sel_end_line) {
            // just end
            rect(
              0, 
              LINE_HEIGHT * (i - viewport_line), 
              CHAR_WIDTH * sel_end_char, 
              LINE_HEIGHT
            );
          } else {
            // full line
            rect(
              0, 
              LINE_HEIGHT * (i - viewport_line), 
              WIDTH, 
              LINE_HEIGHT
            );
          }
        }
      }

      // text
      pushMatrix();
        textFont(sourceCodePro);
        textSize(TEXT_SIZE);
        for (
          int i = viewport_line; 
          i < viewport_line + VIEWPORT_N_LINES; 
          i ++
        ) {
          if (i >= lines.length) {
            break;
          }
          pushMatrix();
            Line.Span span = lines[i].root;
            while (span != null) {
              fill(span.c);
              text(span.text, 0, 0);
              translate(CHAR_WIDTH * span.text.length(), 0);
              span = span.next;
            }
          popMatrix();
          translate(0, LINE_HEIGHT);
        }
      popMatrix();

      // cursor
      if (
        millis() % (CURSOR_BLINK_INTERVAL * 2) 
        < CURSOR_BLINK_INTERVAL
      ) {
        stroke(0);
        line(
          CHAR_WIDTH * sel_start_char, 
          LINE_HEIGHT * rel_sel_line, 
          CHAR_WIDTH * sel_start_char, 
          LINE_HEIGHT * (rel_sel_line + 1)
        );
        noStroke();
      }
    popMatrix();
  }
}
