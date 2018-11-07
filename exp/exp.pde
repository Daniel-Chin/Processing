PImage i;

void setup () {
  i = loadImage("1.bmp");
  background(255);
  size(200, 200);
  smooth(0);
}

void draw() {
 image(i, 0, 0, 200, 200); 
}
