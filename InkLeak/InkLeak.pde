/*
auto correct crossing
 random flip crossing
 with or without debug
 */
final int WIGGLE_NOISE_UNCORRELATE = 100;
final int EDGE_TIMES = 1;
float CLEAR = .15f; //.015 .25 .15
final boolean BORDER = true;

class Node {
  public int x;
  public int y;
  public float angle;
  public int length;
  public int wiggle_speed = 2;
  public int wiggle_size;
  public int effective_x;
  public int effective_y;

  protected float noise_phase = 0f;

  public Node(int x, int y, int length, float angle) {
    this.x = x;
    this.y = y;
    this.effective_x = x;
    this.effective_y = y;
    this.length = length;
    this.angle = angle;
    this.noise_phase = random(WIGGLE_NOISE_UNCORRELATE);
    this.wiggle_size = (int) (length * .9f);
  }

  public Node(int x, int y, int length) {
    this(x, y, length, 0);
  }

  public Node(PVector a, PVector b) {
    this(
      (int) ((a.x + b.x) / 2), 
      (int) ((a.y + b.y) / 2), 
      (int) sqrt(sq(a.x - b.x) + sq(a.y - b.y)), 
      b.sub(a).heading()
      );
  }

  public void doWiggle() {
    if (this.wiggle_speed != 0) {
      this.noise_phase += (float) this.wiggle_speed * 0.01f;
      float offset = (noise(this.noise_phase) - .5f) * (float) this.wiggle_size;
      this.effective_x = this.x + (int) (offset * cos(this.angle));
      this.effective_y = this.y + (int) (offset * sin(this.angle));
    }
  }

  public PVector sample() {
    float beta = random(this.length) - (float) this.length * .5f;
    return new PVector(
      this.effective_x + (int) (beta * cos(this.angle)), 
      this.effective_y + (int) (beta * sin(this.angle)) 
      );
  }

  public void correlateNoise(Node that) {
    this.noise_phase = that.noise_phase;
  }

  public void orientWith(Node that) {
    PVector perpendi = new PVector(this.y - that.y, that.x - this.x);
    if (
      PVector.fromAngle(this.angle).dot(perpendi)
      * PVector.fromAngle(that.angle).dot(perpendi)
      < 0
    ) {
      this.angle += PI;
    }
  }
  
  public Node setWiggleSize(int x) {
      this.wiggle_size = x;
      return this;
  }
  
  public Node setWiggleSpeed(int x) {
      this.wiggle_speed = x;
      return this;
  }
}

class Edge {
  public Node nodeA;
  public Node nodeB;

  public Edge(Node a, Node b) {
    this.nodeA = a;
    this.nodeB = b;
  }

  public void draw() {
    PVector pointA;
    PVector pointB;
    for (int i = 0; i < EDGE_TIMES; i ++) {
      pointA = this.nodeA.sample();
      pointB = this.nodeB.sample();
      line(pointA.x, pointA.y, pointB.x, pointB.y);
    }
    if (BORDER) {
      int hori_a = int(this.nodeA.length * cos(this.nodeA.angle) / 2);
      int vert_a = int(this.nodeA.length * sin(this.nodeA.angle) / 2);
      int hori_b = int(this.nodeB.length * cos(this.nodeB.angle) / 2);
      int vert_b = int(this.nodeB.length * sin(this.nodeB.angle) / 2);
      line(
        this.nodeA.effective_x - hori_a, this.nodeA.effective_y - vert_a, 
        this.nodeB.effective_x - hori_b, this.nodeB.effective_y - vert_b
        );
      line(
        this.nodeA.effective_x + hori_a, this.nodeA.effective_y + vert_a, 
        this.nodeB.effective_x + hori_b, this.nodeB.effective_y + vert_b
        );
    }
  }
}

class InkLeakCanvas {
  public ArrayList<Node> nodes;
  public ArrayList<Edge> edges;

  private Node lastNode = null;

  public InkLeakCanvas() {
    this.nodes = new ArrayList<Node>();
    this.edges = new ArrayList<Edge>();
  }

  public Node add(Node node) {
    this.nodes.add(node);
    return node;
  }

  public Edge link(Node a, Node b) {
    Edge edge = new Edge(a, b);
    this.edges.add(edge);
    return edge;
  }

  public Node extend(Node node, boolean do_correlate_noise) {
    if (do_correlate_noise) {
      node.correlateNoise(this.lastNode);
    }
    node.orientWith(this.lastNode);
    this.add(node);
    this.link(this.lastNode, node);
    this.lastNode = node;
    return node;
  }

  public Node extend(Node node) {
    return this.extend(node, false);
  }

  public Node start(Node node) {
    this.add(node);
    this.lastNode = node;
    return node;
  }

  public void wiggleAndDraw() {
    for (Node node : this.nodes) {
      node.doWiggle();
    }
    for (Edge edge : this.edges) {
      edge.draw();
    }
  }
}

void echoClear(int x1, int y1, int x2, int y2) {
  int w = x2 - x1;
  int h = y2 - y1;
  int times = (int) ((float) abs(h) * CLEAR);
  for (int i = 0; i < times; i ++) {
    line(
      random(w) + x1, 
      random(h) + y1, 
      random(w) + x1, 
      random(h) + y1
      );
  }
}

InkLeakCanvas canvas;
void setup() {
  size(1200, 600);
  canvas = new InkLeakCanvas();
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

void draw() {
  stroke(#2F768C);
  echoClear(0, 0, width, height);
  stroke(255);
  canvas.wiggleAndDraw();
}

