// Demo
class NextSceneButton extends Button {
  public NextSceneButton() {
    position=new PVector(30, 100);
    _size.x = 200;
    _text = "next scene";
  }

  void onClick() {
    println("click");
    director.push(this);
    director.enterScene(new Scene2());
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
    director.pop();
    director.enterScene(scene1);
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

class Scene2 extends Layer {
  Scene2() {
    super();
    title = "scene 2 with no purpose";
    Button b3 = new BackButton();
    add(b3);
  }
}

Scene1 scene1;
Layer subLayer1;

void setup() {
  size(500, 500);
  scene1 = new Scene1();
  scene1.title = "scene 1";
  director.enterScene(scene1);
  scene1.button = new ToggleButton();
  scene1.add(scene1.button);
  subLayer1 = new Layer();
  scene1.add(subLayer1);
  NextSceneButton button2 = new NextSceneButton();
  subLayer1.add(button2);
  DemoSlider slider = new DemoSlider();
  subLayer1.add(slider);
  subLayer1.add(new Card("display", 300f, 200f, 150f, 60f));
}

void draw() {
  background(100);
  director.render();
}
