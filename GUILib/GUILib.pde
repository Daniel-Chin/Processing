// Demo
class DemoButton extends Button {
  public DemoButton() {
    position=new PVector(100, 100);
    _size.x = 200;
    _text = "demo";
  }

  void onClick() {
    println("click");
  }

  void onPress() {
    super.onPress();
    println("press");
  }

  void onDrag(float delta_x, float delta_y) {
    print("drag ");
    println(delta_x, delta_y);
  }

  void onRelease() {
    super.onRelease();
    println("release");
  }
}

class DemoSlider extends Slider {
  DemoSlider() {
    super(width / 2f, 0f, width / 2f, height * .2f);
  }
  void onChange() {
    ((Scene1) this.parent.parent).button._text = str(getValue());
  }
}

class Scene1 extends Layer {
  Button button;
}

Scene1 scene1;

void setup() {
  size(500, 500);
  scene1 = new Scene1();
  GUIGlobal.root = scene1;
  scene1.button = new DemoButton();
  scene1.add(scene1.button);
  Layer subLayer1 = new Layer();
  scene1.add(subLayer1);
  subLayer1.position = new PVector(0f, height / 2f);
  subLayer1._size = new PVector(1f, .5f);
  Button button2 = new Button("does nothing", 0, 0, (float)height, width/2);
  subLayer1.add(button2);
  DemoSlider slider = new DemoSlider();
  subLayer1.add(slider);
}

void draw() {
  background(100);
  GUIGlobal.root.draw();

}
