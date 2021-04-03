import java.awt.event.KeyEvent;

static final int[] C_TOP = {20, 42, 62};
static final int[] C_MID = {2, 4, 7};
static final float C_SMOOTH = .02;
static final int TEXTBOX_LEFT = 65;
static final int TEXTBOX_TOP = 122;

PFont sourceCodePro;
PFont sourceCodeProBold;
PFont arial;
PFont arialBold;

TextBox textBox;

void setup() {
  size(1030, 810);
  
  initGOD();

  sourceCodePro = createFont(
    "sourcecodepro/SourceCodePro-Regular.ttf", 
    TextBox.TEXT_SIZE
  );
  sourceCodeProBold = createFont(
    "sourcecodepro/SourceCodePro-Bold.ttf", 
    TextBox.TEXT_SIZE
  );
  arial = createFont(
    "arial", 18
  );
  arialBold = createFont(
    "arial bold", 18
  );
  textBox = new TextBox(quine());
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
  handleScrollbarSeek();

  if (inTextBox()) {
    cursor(TEXT);
  } else {
    cursor(ARROW);
  }
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
    fill(0);  // black back
    rect(0, 0, width, 200);
    fill(130, 140, 150);  // top
    rect(0, 0, width, 41);
    pushMatrix();
      translate(948, 0);
      stroke(0);
      strokeWeight(1.2);
      fill(130, 140, 150);
      rect(10, 10, 12, 17);
      rect(16, 12, 12, 17);

      translate(53, 22);
      triangle(0, 0, 15, 7, 15, -7);
      noStroke();
    popMatrix();
    pushMatrix();
      translate(0, 165);
      fill(45, 66, 81); // bottom, ceil
      rect(0, 0, width, -4);
      fill(18, 37, 54); // bottom, main
      rect(0, 0, width, 100);
      drawBottomBar(
        height - (TEXTBOX_TOP + TextBox.HEIGHT) - 165f
      );
    popMatrix();
  popMatrix();
}

void drawBottomBar(float _height) {
  pushMatrix();
    translate(65, 0);
    fill(45, 66, 81);
    rect(0, 0, 150, _height - 4, 0, 0, 0, 8);

    fill(224, 255, 253);
    rect(20, 10, 26, 20);
    textFont(arialBold, 16);
    text("Console", 60, 12);
    fill(45, 66, 81);
    text(">_", 23, 9);

    translate(153, 0);
    fill(31, 50, 65);
    rect(0, 0, 134, _height - 4, 0, 0, 8, 0);

    fill(149, 173, 176);
    text("Errors", 60, 12);
    translate(30, 20);
    triangle(0, -13, -13, 11, 13, 11);
    fill(45, 66, 81);
    textAlign(CENTER);
    textFont(sourceCodeProBold, 20);
    text("!", -1, 8);
    textAlign(LEFT, TOP);
  popMatrix();
}

void drawTopBar() {
  pushMatrix();
    translate(88, 40);
    fill(168, 173, 178);
    ellipse(0, 0, 46, 46);
    fill(20, 42, 61);
    triangle(-5, -9, -5, 9, 10, 0);

    translate(60, 0);
    fill(168, 173, 178);
    ellipse(0, 0, 46, 46);
    fill(20, 42, 61);
    rect(-7, -7, 14, 14);

    translate(733, 0);
    fill(168, 173, 178);
    ellipse(0, 0, 46, 46);
    stroke(20, 42, 61);
    strokeWeight(2.5);
    for (int i = 0; i < 2; i ++) {
      line(3, -10, 5.5, -11.5);
      line(3, -10, 3, 8);
      ellipse(6.5, 0, 7.5, 7.5);
      ellipse(6.5, 9, 7.5, 7.5);
      scale(-1, 1);
    }

    translate(39, -23);
    stroke(58, 80, 94);
    strokeWeight(1.5);
    noFill();
    rect(0, 0, 90, 46);
    noStroke();
    translate(20, 23);
    fill(255);
    textFont(arial, 17);
    text("Java", 0, -11);
    translate(48, 0);
    triangle(-5, -5, 5, -5, 0, 5);
  popMatrix();
  
  pushMatrix();
    translate(TEXTBOX_LEFT, TEXTBOX_TOP - 42);
    fill(224, 255, 253);
    rect(0, 0, 100, 42, 8, 0, 0, 0);
    fill(0);
    textFont(arialBold, 18);
    textAlign(CENTER);
    text(getClass().getName(), 50, 28);
    textAlign(LEFT, TOP);

    translate(100, 0);
    fill(45, 66, 81);
    rect(0, 0, 33, 42, 0, 8, 0, 0);
    fill(255);
    translate(19, 21);
    triangle(-5, -5, 5, -5, 0, 5);
  popMatrix();
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
  int cursor_phase = 0;

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

      identifyComments();
      identifyStrings();
      parseTokens();

      colorize("static", 51, 153, 126);
      colorize("final", 51, 153, 126);
      colorize("import", 51, 153, 126);
      colorize("void", 51, 153, 126);
      colorize("class", 51, 153, 126);
      colorize("null", 51, 153, 126);
      colorize("true", 51, 153, 126);
      colorize("false", 51, 153, 126);
      colorize("assert", 51, 153, 126);
      colorize("new", 51, 153, 126);
      colorize("this", 51, 153, 126);
      colorize("return", 51, 153, 126);
      colorize("indexOf", 51, 153, 126);
      colorize("continue", 51, 153, 126);
      colorize("break", 51, 153, 126);
      
      colorize("float", 226, 102, 26);
      colorize("int", 226, 102, 26);
      colorize("PFont", 226, 102, 26);
      colorize("boolean", 226, 102, 26);
      colorize("color", 226, 102, 26);
      colorize("String", 226, 102, 26);

      colorize("setup", 0, 102, 153, true);
      colorize("draw", 0, 102, 153, true);
      colorize("mousePressed", 0, 102, 153, true);
      colorize("mouseDragged", 0, 102, 153, true);
      colorize("mouseReleased", 0, 102, 153, true);
      colorize("mouseWheel", 0, 102, 153, true);

      colorize("size", 0, 102, 153);
      colorize("textAlign", 0, 102, 153);
      colorize("pushMatrix", 0, 102, 153);
      colorize("popMatrix", 0, 102, 153);
      colorize("rect", 0, 102, 153);
      colorize("ellipse", 0, 102, 153);
      colorize("line", 0, 102, 153);
      colorize("triangle", 0, 102, 153);
      colorize("text", 0, 102, 153);
      colorize("fill", 0, 102, 153);
      colorize("noFill", 0, 102, 153);
      colorize("stroke", 0, 102, 153);
      colorize("noStroke", 0, 102, 153);
      colorize("scale", 0, 102, 153);
      colorize("translate", 0, 102, 153);
      colorize("substring", 0, 102, 153);
      colorize("char", 0, 102, 153);
      colorize("length", 0, 102, 153);
      colorize("charAt", 0, 102, 153);
      colorize("equals", 0, 102, 153);
      colorize("splitTokens", 0, 102, 153);
      colorize("mix", 0, 102, 153);
      colorize("max", 0, 102, 153);
      colorize("constrain", 0, 102, 153);
      colorize("textFont", 0, 102, 153);
      colorize("textSize", 0, 102, 153);
      colorize("millis", 0, 102, 153);
      colorize("round", 0, 102, 153);
      colorize("beginShape", 0, 102, 153);
      colorize("vertex", 0, 102, 153);
      colorize("endShape", 0, 102, 153);

      colorize("LEFT", 113, 138, 98);
      colorize("RIGHT", 113, 138, 98);
      colorize("TOP", 113, 138, 98);
      colorize("TEXT", 113, 138, 98);
      colorize("ARROW", 113, 138, 98);
      colorize("CLOSE", 113, 138, 98);
      colorize("CODED", 113, 138, 98);
      colorize("UP", 113, 138, 98);
      colorize("DOWN", 113, 138, 98);

      colorize("width", 217, 74, 122);
      colorize("height", 217, 74, 122);
      colorize("mouseX", 217, 74, 122);
      colorize("mouseY", 217, 74, 122);
      colorize("key", 217, 74, 122);
      colorize("keyCode", 217, 74, 122);

      colorize("for", 102, 153, 0);
      colorize("if", 102, 153, 0);
      colorize("else", 102, 153, 0);
      colorize("while", 102, 153, 0);
      colorize("switch", 102, 153, 0);
    }

    void identifyComments() {
      int pos = root.text.indexOf("/" + "/");
      if (pos == -1) {
        return;
      }
      Span comment = root.splitAt(pos);
      comment.c = color(102);
    }

    void identifyStrings() {
      Span cursor = root;
      int pos;
      Span willDo;
      while (cursor != null) {
        if (cursor.c != 0) {  // a string, or a comment
          cursor = cursor.next;
          continue;
        }
        pos = cursor.text.indexOf(char(34));
        if (pos == -1) {
          break;
        }
        cursor = cursor.splitAt(pos);

        pos = cursor.text.substring(1).indexOf(
          char(34)
        ) + 1;
        assert pos != 0;
        willDo = cursor.splitAt(pos + 1);
        cursor.c = color(125, 71, 147);
        cursor = willDo;
      }
    }

    boolean isToken(char x) {
      int ascii = int(x);
      return x == '_' || (
        (65 <= ascii && ascii < 91) || 
        (97 <= ascii && ascii < 123)
      );
    }

    void parseTokens() {
      Span cursor = root;
      while (cursor != null) {
        if (cursor.c != 0) {  // a string, or a comment
          cursor = cursor.next;
          continue;
        }
        if (cursor.text.length() != 0) {
          boolean is_token = isToken(cursor.text.charAt(0));
          boolean did_split = false;
          for (int i = 1; i < cursor.text.length(); i ++) {
            if (is_token != isToken(cursor.text.charAt(i))) {
              cursor = cursor.splitAt(i);
              did_split = true;
              break;
            }
          }
          if (did_split) {
            continue;
          }
        }
        cursor = cursor.next;
      }

      // cursor = root;
      // while (cursor != null) {
      //   print(cursor.text);
      //   print("|");
      //   cursor = cursor.next;
      // }
      // println();
    }

    void colorize(String keyword, int r, int g, int b) {
      colorize(keyword, r, g, b, false);
    }
    void colorize(String keyword, int r, int g, int b, boolean do_bold) {
      Span cursor = root;
      while (cursor != null) {
        if (cursor.c != 0) {  // a string, or a comment
          cursor = cursor.next;
          continue;
        }
        if (cursor.text.equals(keyword)) {
          cursor.c = color(r, g, b);
          cursor.bold = do_bold;
        }
        cursor = cursor.next;
      }
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
    fill(255);
    rect(0, 0, WIDTH, HEIGHT);

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
              if (span.bold) {
                textFont(sourceCodeProBold);
              }
              text(span.text, 0, 0);
              textFont(sourceCodePro);
              translate(CHAR_WIDTH * span.text.length(), 0);
              span = span.next;
            }
          popMatrix();
          translate(0, LINE_HEIGHT);
        }
      popMatrix();

      // cursor
      if (
        (millis() - cursor_phase) % (CURSOR_BLINK_INTERVAL * 2) 
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
            TEXTBOX_LEFT + TextBox.WIDTH, 
            TEXTBOX_TOP + y, 
            SCROLLBAR_WIDTH, 
            SCROLLBAR_WIDTH
          )) {
            fill(218);
            rect(0, 0, SCROLLBAR_WIDTH, SCROLLBAR_WIDTH);
            if (
              click_scroll_button_cooldown < millis()
              && mousePressed && (! dragSelecting)
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
      int chunk_y = round(
        SCROLL_BAR_DOMAIN * viewport_line / float(
          lines.length - VIEWPORT_N_LINES
        ) + SCROLLBAR_WIDTH
      );
      if (inScrollBar()) {
        fill(166);
      } else {
        fill(205);
      }
      rect(
        0, 
        chunk_y, 
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
    sel_end_char = max(0, sel_end_char);
    sel_start_char = max(0, sel_start_char);
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
    // TEXTBOX_LEFT, 
    0, 
    TEXTBOX_TOP, 
    // TextBox.WIDTH, 
    TextBox.WIDTH + TEXTBOX_LEFT, 
    TextBox.HEIGHT
  );
}
boolean inScrollBar() {
  return inRect(
    TEXTBOX_LEFT + TextBox.WIDTH, 
    TEXTBOX_TOP + TextBox.SCROLLBAR_WIDTH, 
    TextBox.SCROLLBAR_WIDTH, 
    TextBox.HEIGHT - 2 * TextBox.SCROLLBAR_WIDTH
  );
}

boolean dragSelecting = false;
boolean draggingScrollbar = false;
void mousePressed() {
  if (inTextBox()) {
    int[] parsed = textBox.parseMouse();
    textBox.sel_start_char = parsed[0];
    textBox.sel_start_line = parsed[1];
    textBox.sel_end_char = parsed[0];
    textBox.sel_end_line = parsed[1];
    dragSelecting = true;
  }

  if (inScrollBar()) {
    draggingScrollbar = true;
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
  draggingScrollbar = false;
}

int selection_scroll_cooldown = 0;
int selection_scrolling = 0;
void handleSelectionScroll() {
  if (dragSelecting) {
    if (mouseY < TEXTBOX_TOP) {
      selection_scrolling = -1;
    } else if (mouseY > TEXTBOX_TOP + TextBox.HEIGHT) {
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

void handleScrollbarSeek() {
  if (draggingScrollbar) {
    float progress = (mouseY - (
      TEXTBOX_TOP + TextBox.SCROLLBAR_WIDTH
    )) / float(
      TextBox.HEIGHT - 2 * TextBox.SCROLLBAR_WIDTH
    );
    textBox.viewport_line = round(progress * (
      textBox.lines.length - TextBox.VIEWPORT_N_LINES
    ));
    textBox.normalizeViewport();
  }
}

void keyPressed() {
  if (key == CODED) {
    println("keyCode:", keyCode);
    switch (keyCode) {
      case UP:
        textBox.sel_end_line -= 1;
        break;
      case DOWN:
        textBox.sel_end_line += 1;
        break;
      case LEFT:
        textBox.sel_end_char -= 1;
        break;
      case RIGHT:
        textBox.sel_end_char += 1;
        break;
      case KeyEvent.VK_PAGE_UP:
        textBox.sel_end_line -= TextBox.VIEWPORT_N_LINES;
        break;
      case KeyEvent.VK_PAGE_DOWN:
        textBox.sel_end_line += TextBox.VIEWPORT_N_LINES;
        break;
      case KeyEvent.VK_END:
        textBox.sel_end_char = 56;
        break;
      case KeyEvent.VK_HOME:
        textBox.sel_end_char = 0;
        break;
      default:
        return;
    }
    textBox.normalizeSelection();
    textBox.sel_start_char = textBox.sel_end_char;
    textBox.sel_start_line = textBox.sel_end_line;
    textBox.viewportFollowSelection();
    textBox.cursor_phase = millis();
  }
}

String[] quine() {
  int gl = GOD.length;
  String[] result = new String[
    gl * 2 + (gl / 100 + 1) * 3 + 2
  ];
  int line_i = 0;
  while (line_i < gl) {
    result[line_i] = new String(GOD[line_i]);
    line_i ++;
  }
  result[line_i] = "  GOD = new char[" + String.valueOf(
    gl
  ) + "][];";
  line_i ++;
  for (int i = 0; i < gl; i ++) {
    if (i % 100 == 0) {
      String newGOD = "initGod" + String.valueOf(
        i / 100
      ) + "()";
      result[line_i] = "  " + newGOD + ";";
      line_i ++;
      result[line_i] = "}";
      line_i ++;
      result[line_i] = "void " + newGOD + " {";
      line_i ++;
    }
    StringBuilder line = new StringBuilder();
    line.append("  GOD[");
    line.append(String.valueOf(i));
    line.append("] = new char[] {");
    for (int j = 0; j < GOD[i].length; j ++) {
      line.append(String.valueOf(int(GOD[i][j])));
      line.append(", ");
    }
    line.append("};");
    result[line_i] = line.toString();
    line_i ++;
  }
  result[line_i] = "}";
  return result;
}

char[][] GOD;

void initGOD() {
  GOD = new char[2][];
  GOD[0] = new char[] {'a', 's'};
  GOD[1] = new char[] {'a', 's'};
}
