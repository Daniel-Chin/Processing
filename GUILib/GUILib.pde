// Demo
class NextSceneButton extends Button {
  public NextSceneButton() {
    position=new PVector(150, 400);
    _size.x = 200;
    _text = "next scene";
  }

  void onClick() {
    println("click");
    GUIGlobal.root = scene2;
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
    super(100, 300, 300, 50);
  }
  void onChange() {
    ((Scene1) this.parent.parent).button._text = str(getValue());
  }
}

class Scene1 extends Layer {
  ToggleButton button;
}

class BackButton extends Button {
  BackButton () {
    super("back", 50f, 50f, 100f, 100f);
  }
  void onClick() {
    GUIGlobal.root = scene1;
  }
}

class ToggleButton extends Button {
  ToggleButton () {
    super("toggle", 350f, 50f, 100f, 100f);
  }
  void onClick() {
    subLayer1.toggleVisibility();
  }
}

Scene1 scene1;
Layer subLayer1;
Layer scene2;

void setup() {
  size(500, 500);
  scene1 = new Scene1();
  scene1.title = "scene 1";
  GUIGlobal.root = scene1;
  scene1.button = new ToggleButton();
  scene1.add(scene1.button);
  subLayer1 = new Layer();
  scene1.add(subLayer1);
  NextSceneButton button2 = new NextSceneButton();
  subLayer1.add(button2);
  DemoSlider slider = new DemoSlider();
  subLayer1.add(slider);

  scene2 = new Layer();
  scene2.title = "scene 2 with no purpose";
  Button b3 = new BackButton();
  scene2.add(b3);
}

void draw() {
  background(100);
  GUIGlobal.root.draw();

}
