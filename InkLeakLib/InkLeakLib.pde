InkLeakCanvas canvas;
Timer t;
Timer t2;
void setup() {
  size(1200, 600);
  delay(3000);
  canvas = new InkLeakCanvas();
  canvas.do_border = true;
  t = new Timer();
  t2 = new Timer();
  canvas.start(new Node(168, 231, 50, PI / 2));
  canvas.extend(new Node(231, 222, 50, PI / 2));
  canvas.extend(new Node(333, 188, 50, PI / 2));
  canvas.start(new Node(262, 213, 63, 0));
  canvas.extend(new Node(new PVector(296, 420), new PVector(230, 453)));
  canvas.start(new Node(488, 208, 60, PI / 2));
  canvas.extend(new Node(404, 186, 53, PI / 2));
  canvas.extend(new Node(new PVector(352, 160), new PVector(404, 212)), true);
  canvas.extend(new Node(new PVector(401, 325), new PVector(352, 399)));
  // canvas.extend(new Node(new PVector(455, 337), new PVector(448, 407)));
  canvas.extend(new Node(new PVector(484, 349), new PVector(484, 415)));
  canvas.start(new Node(377, 261, 58, PI / 2));
  canvas.extend(new Node(458, 276, 55, PI / 2));
  canvas.start(new Node(new PVector(500, 420), new PVector(557, 436)));
  canvas.extend(new Node(new PVector(503, 180), new PVector(559, 200)));
  canvas.extend(new Node(new PVector(590, 276), new PVector(589, 356)));
  canvas.extend(new Node(new PVector(616, 214), new PVector(665, 219)));
  canvas.extend(new Node(new PVector(619, 452), new PVector(670, 431)));
  canvas.start(new Node(712, 466, 45, 0));
  canvas.extend(new Node(new PVector(684, 223), new PVector(731, 270)));
  canvas.extend(new Node(new PVector(761, 264), new PVector(789, 196)));
  canvas.extend(new Node(new PVector(768, 267), new PVector(812, 217)));
  canvas.extend(new Node(new PVector(763, 315), new PVector(793, 348)));
  canvas.extend(new Node(717, 341, 45, PI / 2));
  canvas.start(new Node(826, 201, 52, - PI / 2));
  canvas.extend(new Node(new PVector(871, 220), new PVector(886, 163)), true);
  canvas.extend(new Node(new PVector(940, 219), new PVector(925, 162)));
  canvas.extend(new Node(1000, 207, 58, - PI / 2), true);
  canvas.start(new Node(905, 201, 74, 0));
  canvas.extend(new Node(new PVector(883, 439), new PVector(945, 413)))
    //    .setWiggleSize(200)
    //    .setWiggleSpeed(6)
    ;
  /* the ■
   Node n1 = canvas.start(new Node(new PVector(983, 249), new PVector(976, 343)));
   canvas.extend(new Node(new PVector(1041, 272), new PVector(1091, 285)));
   canvas.extend(new Node(new PVector(1079, 352), new PVector(1093, 412)));
   Node n2 = canvas.extend(new Node(new PVector(1039, 421), new PVector(982, 450)));
   canvas.link(n1, n2);
   */
}

float density = .25f;
void draw() {
  while (t.spin(550)) {
    density = 0f;
    canvas.edge_times = 15;
  }
  while (t2.spin(16)) {
    density += .015f;
    canvas.edge_times --;
    if (density >= .25f) {
        density = .25f;
    }
    if (canvas.edge_times == 0) {
        canvas.edge_times = 1;
    }
  }
  stroke(#2F768C);
  echoClear(density);
  stroke(255);
  canvas.wiggleAndDraw();
}
