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
