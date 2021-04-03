// cahnge to actual quine

static final int[] C_TOP = {20, 42, 62};
static final int[] C_MID = {2, 4, 7};
static final float C_SMOOTH = .02;
static final int TEXTBOX_LEFT = 65;
static final int TEXTBOX_TOP = 122;

PFont sourceCodePro;

TextBox textBox;

void setup() {
  size(1030, 810);
  sourceCodePro = createFont(
    "sourcecodepro/SourceCodePro-Regular.ttf", 
    TextBox.TEXT_SIZE
  );
  textBox = new TextBox(loadStrings("quine.pde"));
  noStroke();
  textAlign(LEFT, TOP);
}

void draw() {
  drawBack();
  drawTopBar();
  pushMatrix();
    translate(TEXTBOX_LEFT, TEXTBOX_TOP);
    textBox.draw();
  popMatrix();
  drawLow();

  handleSelectionScroll();
}

void drawBack() {
  pushMatrix();
    scale(width, TEXTBOX_TOP + TextBox.HEIGHT);
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
    translate(0, TEXTBOX_TOP + TextBox.HEIGHT);
    fill(0);
    rect(0, 0, width, 200);
    fill(130, 140, 150);
    rect(0, 0, width, 41);
    fill(45, 66, 81);
    rect(0, 150, width, 4);
    fill(18, 37, 54);
    rect(0, 154, width, 100);
    pushMatrix();
      translate(0, 154);
      drawBottomBar(
        height - (TEXTBOX_TOP + TextBox.HEIGHT) - 154f
      );
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
  rect(65, 122, 945, TEXTBOX_TOP + TextBox.HEIGHT);
}

class TextBox {
  static final int VIEWPORT_N_LINES = 14;
  static final int LINE_HEIGHT = 35;
  static final int WIDTH = 920;
  static final int HEIGHT = 476;
  static final int TEXT_SIZE = 27;
  float CHAR_WIDTH = TEXT_SIZE * .6;
  static final int CURSOR_BLINK_INTERVAL = 500;
  static final int SCROLLBAR_WIDTH = 24;

  Line[] lines;
  int viewport_line = 0;
  int sel_start_line = 0;
  int sel_start_char = 0;
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
        willDo = cursor.splitAt(pos + 1);
        cursor.c = color(125, 71, 147);
        cursor = willDo;
      }
    }

    void colorize(String keyword, int r, int g, int b) {

    }
  }

  TextBox(String[] lines_raw) {
    init(lines_raw);
  }
  TextBox(String src) {
    String[] lines_raw = splitTokens(src, "\n");
    init(lines_raw);
  }
  void init(String[] lines_raw) {
    int n_lines = lines_raw.length;
    lines = new Line[n_lines];
    for (int i = 0; i < n_lines; i ++) {
      lines[i] = new Line(lines_raw[i]);
    }
  }

  void draw() {
    int rel_sel_line = sel_end_line - viewport_line;

    if (
      0 <= rel_sel_line 
      && rel_sel_line < VIEWPORT_N_LINES
    ) {
      // line number highlight
      fill(88, 116, 120);
      rect(
        0, LINE_HEIGHT * rel_sel_line, 
        -100, LINE_HEIGHT
      );

      // current line highlight
      if (! isSelectingMulti()) {
        fill(235, 255, 253);
        rect(
          0, LINE_HEIGHT * rel_sel_line, 
          WIDTH, LINE_HEIGHT
        );
      }
    }

    // line numbers
    fill(187, 214, 213);
    textAlign(RIGHT, TOP);
    textSize(17);
    for (int i = 0; i < VIEWPORT_N_LINES; i ++) {
      text(
        String.valueOf(viewport_line + i + 1), 
        -6, LINE_HEIGHT * i + 10
      );
    }
    textAlign(LEFT, TOP);

    // slight left padding
    pushMatrix();
      translate(6, 0);

      // selection background
      fill(255, 204, 0);
      int upper_line;
      int upper_char;
      int lower_line;
      int lower_char;
      if (
        sel_start_line * 1000 + sel_start_char 
        < sel_end_line * 1000 + sel_end_char 
      ) {
        upper_line = sel_start_line;
        upper_char = sel_start_char;
        lower_line = sel_end_line;
        lower_char = sel_end_char;
      } else {
        lower_line = sel_start_line;
        lower_char = sel_start_char;
        upper_line = sel_end_line;
        upper_char = sel_end_char;
      }
      for (
        int i = max(upper_line, viewport_line); 
        i <= min(
          lower_line, viewport_line + VIEWPORT_N_LINES
        ); 
        i ++
      ) {
        if (i == upper_line) {
          if (i == lower_line) {
            // same line
            rect(
              CHAR_WIDTH * upper_char, 
              LINE_HEIGHT * (i - viewport_line), 
              CHAR_WIDTH * (lower_char - upper_char), 
              LINE_HEIGHT
            );
          } else {
            // just start
            rect(
              CHAR_WIDTH * upper_char, 
              LINE_HEIGHT * (i - viewport_line), 
              WIDTH - CHAR_WIDTH * upper_char, 
              LINE_HEIGHT
            );
          }
        } else {
          if (i == lower_line) {
            // just end
            rect(
              0, 
              LINE_HEIGHT * (i - viewport_line), 
              CHAR_WIDTH * lower_char, 
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
          CHAR_WIDTH * sel_end_char, 
          LINE_HEIGHT * (rel_sel_line), 
          CHAR_WIDTH * sel_end_char, 
          LINE_HEIGHT * (rel_sel_line + 1)
        );
        noStroke();
      }
    popMatrix();
    drawScrollBar();
  }

  int[] parseMouse() {
    int[] results = new int[2];
    int x = mouseX - TEXTBOX_LEFT - 6;
    int y = mouseY - TEXTBOX_TOP;
    results[0] = round(x / CHAR_WIDTH);
    results[1] = y / LINE_HEIGHT + viewport_line;
    return results;
  }

  boolean isSelectingMulti() {
    return ! (
      sel_start_line == sel_end_line 
      && sel_start_char == sel_end_char
    );
  }

  void viewportFollowSelection() {
    int delta = sel_end_line - viewport_line;
    if (delta < 0) {
      viewport_line += delta;
    } else {
      delta -= (VIEWPORT_N_LINES - 2);
      if (delta > 0) {
        viewport_line += delta;
      }
    }
  }

  static final int SCROLL_CHUNK_HEIGHT = 10;
  int SCROLL_BAR_DOMAIN = (
    HEIGHT - SCROLL_CHUNK_HEIGHT - 2 * SCROLLBAR_WIDTH
  );
  int click_scroll_button_cooldown = 0;
  void drawScrollBar() {
    pushMatrix();
      translate(WIDTH, 0);

      // buttons
      fill(240);
      rect(0, 0, SCROLLBAR_WIDTH, HEIGHT);
      for (int i = 0; i < 2; i ++) {
        pushMatrix();
          int y = i * (HEIGHT - SCROLLBAR_WIDTH);
          translate(0, y);
          if (inRect(
            TEXTBOX_LEFT + textBox.WIDTH, 
            TEXTBOX_TOP + y, 
            SCROLLBAR_WIDTH, 
            SCROLLBAR_WIDTH
          )) {
            fill(218);
            rect(0, 0, SCROLLBAR_WIDTH, SCROLLBAR_WIDTH);
            if (
              click_scroll_button_cooldown < millis()
              && mousePressed
            ) {
              textBox.viewport_line += round((i - .5) * 2);
              textBox.normalizeViewport();   
              click_scroll_button_cooldown = millis() + 50;       
            }
          }
          fill(96);
          if (i == 1) {
            translate(0, SCROLLBAR_WIDTH);
            scale(1, -1);
          }
          int sw = SCROLLBAR_WIDTH;
          translate(0, -.2 * sw);
          beginShape();
          vertex(sw * .5, sw * .5);
          vertex(sw * .25, sw * .75);
          vertex(sw * .25, sw * .9);
          vertex(sw * .5, sw * .7);
          vertex(sw * .75, sw * .9);
          vertex(sw * .75, sw * .75);
          endShape(CLOSE);
        popMatrix();
      }

      // chunk
      fill(205);
      rect(
        0, 
        SCROLL_BAR_DOMAIN * viewport_line / float(
          lines.length - VIEWPORT_N_LINES
        ) + SCROLLBAR_WIDTH, 
        SCROLLBAR_WIDTH, 
        SCROLL_CHUNK_HEIGHT
      );
    popMatrix();
  }

  void normalizeSelection() {
    sel_end_line = constrain(
      sel_end_line, 
      0, 
      lines.length
    );
  }

  void normalizeViewport() {
    viewport_line = constrain(
      viewport_line, 
      0, 
      lines.length - VIEWPORT_N_LINES + 2
    );     
  }
}

boolean inRect(int x1, int y1, int w, int h) {
  return (
    mouseX > x1 && mouseY > y1 && 
    mouseX < x1 + w && mouseY < y1 + h
  );
}
boolean inTextBox() {
  return inRect(
    TEXTBOX_LEFT, 
    TEXTBOX_TOP, 
    TextBox.WIDTH, 
    TextBox.HEIGHT
  );
}

boolean dragSelecting = false;
void mousePressed() {
  if (inTextBox()) {
    int[] parsed = textBox.parseMouse();
    textBox.sel_start_char = parsed[0];
    textBox.sel_start_line = parsed[1];
    textBox.sel_end_char = parsed[0];
    textBox.sel_end_line = parsed[1];
    dragSelecting = true;
  }
}

void mouseDragged() {
  if (dragSelecting) {
    if (inTextBox()) {
      int[] parsed = textBox.parseMouse();
      textBox.sel_end_char = parsed[0];
      textBox.sel_end_line = parsed[1];
      textBox.normalizeSelection();
      textBox.viewportFollowSelection();
    }
  }
}

void mouseReleased() {
  dragSelecting = false;
  selection_scrolling = 0;
}

int selection_scroll_cooldown = 0;
int selection_scrolling = 0;
void handleSelectionScroll() {
  if (dragSelecting) {
    if (mouseY < TEXTBOX_TOP) {
      selection_scrolling = -1;
    } else if (mouseY > TEXTBOX_TOP + textBox.HEIGHT) {
      selection_scrolling = 1;
    } else {
      selection_scrolling = 0;
    }
  }
  if (selection_scroll_cooldown < millis()) {
    if (selection_scrolling != 0) {
      textBox.sel_end_line += selection_scrolling;
      textBox.normalizeSelection();
      textBox.viewportFollowSelection();
      selection_scroll_cooldown = millis() + 30;
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (inTextBox()) {
    float delta = event.getCount();
    textBox.viewport_line += delta;
    textBox.normalizeViewport();
  }
}
