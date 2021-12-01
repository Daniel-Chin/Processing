// Demo
class NextSceneButton extends Button {
  public NextSceneButton() {
    position=new PVector(30, 50);
    _size.x = 200;
    _text = "next scene";
  }

  void onClick() {
    println("click");
    director.push(this, new Scene2());
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
  }
}

class ToggleButton extends Button {
  ToggleButton () {
    super("toggle 他狗", 350f, 50f, 100f, 100f);
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
PFont verdana;
DemoSlider slider;

void setup() {
  size(500, 500);
  verdana = loadFont("KaiTi-24.vlw");
  textFont(verdana);
  scene1 = new Scene1();
  scene1.title = "scene 1";
  director.enterScene(scene1);
  scene1.button = new ToggleButton();
  scene1.add(scene1.button);
  subLayer1 = new Layer();
  scene1.add(subLayer1);
  NextSceneButton button2 = new NextSceneButton();
  subLayer1.add(button2);
  slider = new DemoSlider();
  subLayer1.add(slider);
  subLayer1.add(new Card("display", 300f, 200f, 150f, 60f));
  demoScrollSelect = new DemoScrollSelect();
  subLayer1.add(demoScrollSelect);
}

int last_sec = 0;
void draw() {
  background(0);
  director.render();
  int sec = millis() / 500;
  if (sec > last_sec) {
    last_sec = sec;
    demoScrollSelect.value = (demoScrollSelect.value + 1) % demoScrollSelect.range;
  }
}

void keyPressed() {
  guiKeyPressed();
}

DemoScrollSelect demoScrollSelect;
class DemoScrollSelect extends ScrollSelect {
  DemoScrollSelect() {
    super(8);
    position = new PVector(10, 200);
    _size = new PVector(40, 270);
  }

  void onUpdate(int value) {
    slider.value = value;
  }
}
