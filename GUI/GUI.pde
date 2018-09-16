static class Pressable {
  static ArrayList<Pressable> all;
  static Pressable dragging;
  static int last_drag_x, last_drag_y;
  static {
    all = new ArrayList<Pressable>();
    dragging = null;
  }
  private boolean visibility;
  public Pressable() {
    all.add(this);
    visibility = true;
  }
  boolean isVisible() {
    return visibility;
  }
  void show() {
    visibility = true;
  }
  void hide() {
    visibility = false;
    if (dragging == this) {
      onRelease();
      dragging = null;
    }
  }
  void onPress(){}
  void onDrag(int delta_x, int delta_y){}
  void onRelease(){}
  boolean beingDragged() {
    return dragging == this;
  }
  void onClick(){}
  boolean isMouseOver(){return false;}
  void release() {
    all.remove(this);
  }
}

void mousePressed() {
  for (Pressable pressable : Pressable.all) {
    if (pressable.isVisible() && pressable.isMouseOver()) {
      pressable.onPress();
      Pressable.dragging = pressable;
      Pressable.last_drag_x = mouseX;
      Pressable.last_drag_y = mouseY;
      break;
    }
  }
}

void mouseReleased() {
  if (Pressable.dragging != null) {
    Pressable.dragging.onRelease();
    if (Pressable.dragging.isMouseOver()) {
      Pressable.dragging.onClick();
    }
    Pressable.dragging = null;
  }
}

void mouseDragged() {
  if (Pressable.dragging != null) {
    Pressable.dragging.onDrag(
      mouseX - Pressable.last_drag_x, 
      mouseY - Pressable.last_drag_y);
    Pressable.last_drag_x = mouseX; 
    Pressable.last_drag_y = mouseY;
  }
}

static class KeyboardListener extends Pressable {
  static KeyboardListener focusing;
  static {
    focusing = null;
  }
  void onKeypress(){}
  void focus() {
    focusing = this;
  }
  void unfocus() {
    focusing = null;
  }
  boolean hasFocus() {
    return focusing == this;
  }
  void hide() {
    super.hide();
    if (focusing == this) {
      focusing = null;
    }
  }
}

void keyPressed() {
  if (KeyboardListener.focusing != null) {
    KeyboardListener.focusing.onKeypress();
  }
}

class Button extends Pressable {
  int x, y, _width, _height;
  String _text; 
  int fontsize;
  color back;
  color fore;
  color highlight;
  int press_sink_depth;
  private boolean floating;
  private float float_progress;
  
  public Button(String _text, int x, int y, int _width, int _height) {
    this._text = _text;
    this.x = x;
    this.y = y;
    this._width = _width;
    this._height = _height;
    fontsize = 30;
    back = #000000;
    fore = #FFFFFF;
    highlight = #005555;
    press_sink_depth = 5;
    floating = false;
  }
  
  public Button() {
    this("", 0, 0, 100, 100);
  }
  
  void draw() {
    stroke(fore);
    strokeWeight(2);
    if (isMouseOver()) {
      fill(highlight);
    } else {
      fill(back);
    }
    pushMatrix();
    if (beingDragged()) {
      translate(press_sink_depth, press_sink_depth);
      floating = true;
      float_progress = press_sink_depth;
    } else {
      if (floating) {
        float_progress *= .8;
        if (float_progress < 1) {
          floating = false;
        } else {
          translate(float_progress, float_progress);
        }
      }
    }
    rect(x, y, _width, _height);
    textSize(fontsize);
    fill(fore);
    textAlign(CENTER, CENTER);
    text(_text, x, y - fontsize/8, _width, _height);
    popMatrix();
  }
  
  boolean isMouseOver() {
    return x<mouseX && mouseX<x+_width 
            && y<mouseY && mouseY<y+_height;
  }
}

class Slider extends KeyboardListener{
  class Arrow extends Button {
    Slider parent;
    public Arrow(Slider parent, String left_or_right) {
      this.parent = parent;
      fontsize = 36;
      if (left_or_right == "<") {
        _text = "<";
        x = parent.x;
        y = parent.y;
        _width = parent._height;
        _height = parent._height;
      } else {
        _text = ">";
        x = parent.x + parent._width - parent._height;
        y = parent.y;
        _width = parent._height;
        _height = parent._height;
      }
    }
    
    void onClick() {
      parent.arrowClick(_text);
    }
  }
  private int x, y, _width, _height;
  int box_width;
  int _min, _max;
  private float value;
  private Arrow leftArrow, rightArrow;
  int fontsize;
  color line_color;
  int line_width;
  color box_fore;
  color box_back;
  color box_highlight;
  color box_selected;
  float hint_fontsize_ratio;
  private boolean click_or_drag;
  private String input_value;
  
  public Slider(int x, int y, int _width, int _height) {
    this.x = x;
    this.y = y;
    this._width = _width;
    this._height = _height;
    box_width = 100;
    _min = 0; _max = 100;
    value = _max;
    leftArrow = new Arrow(this, "<");
    rightArrow = new Arrow(this, ">");
    fontsize = 30;
    line_color = #FFFFFF;
    line_width = 2;
    box_fore = #FFFFFF;
    box_back = #000000;
    box_highlight = #005555;
    box_selected = #0000cc;
    hint_fontsize_ratio = .6;
  }
  
  private void arrowClick(String left_or_right) {
    if (hasFocus()) return;
    if (left_or_right == "<") {
      value --;
    } else {
      // >
      value ++;
    }
    legalizeValue();
  }
  
  private void legalizeValue() {
    if (value < _min) value = _min;
    if (value > _max) value = _max;
  }
  
  private int slideSpace() {
    return _width - 2*_height - box_width;
  }
  
  void onPress() {
    if (hasFocus()) return;
    click_or_drag = true;
  }
  
  void onDrag(int delta_x, int delta_y) {
    if (hasFocus()) return;
    click_or_drag = false;
    value += (float)delta_x / slideSpace() * (_max - _min);
    legalizeValue();
  }
  
  void onRelease() {
    if (hasFocus()) return;
    value = int(value);
  }
  
  int getValue() {
    return int(value);
  }
  
  void onClick() {
    if (hasFocus()) return;
    if (click_or_drag) {
      focus();
      input_value = "";
    }
  }
  
  void onKeypress() {
    if (keyCode == 10) {
      // Enter
      unfocus();
      if (input_value.length() != 0) {
        value = Integer.parseInt(input_value);
        legalizeValue();
      }
    } else if (48 <= keyCode && keyCode < 58
                || 96 <= keyCode && keyCode < 106) {
      // Number
      input_value += key;
    } else if (keyCode == 8) {
      // Backspace
      if (input_value.length() > 0) {
        input_value = input_value.
          substring(0, input_value.length() - 1);
      }
    }
  }
  
  boolean isMouseOver() {
    int box_x = boxX();
    return box_x < mouseX && mouseX < box_x + box_width
            && y < mouseY && mouseY < y + _height;
  }
  
  private int boxX() {
    float proportion = ((float)(value - _min)) 
                        / (_max - _min);
    return int(slideSpace() * proportion) + x + _height;
  }
  
  void draw() {
    stroke(line_color);
    strokeWeight(line_width);
    line(x + _height, y + _height/2, 
      x + _width - _height, y + _height/2);
    leftArrow.draw();
    rightArrow.draw();
    // draw box
    strokeWeight(2);
    if (hasFocus()) {
      fill(box_selected);
      stroke(box_fore);
    } else if (beingDragged()) {
      fill(box_fore);
      stroke(box_back);
    } else if (isMouseOver()) {
      fill(box_highlight);
      stroke(box_fore);
    } else {
      fill(box_back);
      stroke(box_fore);
    }
    int box_x = boxX();
    rect(box_x, y, box_width, _height);
    fill(g.strokeColor);
    textSize(fontsize);
    textAlign(CENTER, CENTER);
    String to_draw;
    if (hasFocus()) {
      if (input_value.length() == 0) {
        to_draw = "Type!";
        textSize(fontsize * hint_fontsize_ratio);
      } else {
        to_draw = input_value;
      }
    } else {
      to_draw = String.valueOf(getValue());
    }
    text(to_draw, box_x, y - fontsize/8, box_width, _height);
  }
}


// Demo
class DemoButton extends Button {
  public DemoButton() {
    x=100;
    y=100;
    _width=200;
    _text = "demo";
  }
  
  void onClick() {
    println("click");
  }
  
  void onPress() {
    super.onPress();
    println("press");
  }
  
  void onDrag(int delta_x, int delta_y) {
    println("drag");
  }
  
  void onRelease() {
    super.onRelease();
    println("release");
  }
}

DemoButton button;
Slider s;

void setup() {
  size(500,500);
  button = new DemoButton();
  s = new Slider(100, 400, 300, 50);
}

void draw() {
  background(100);
  button.draw();
  s.draw();
}
