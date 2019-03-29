/*
 maybe features:
    random occurance of angle += PI
 */
final int WIGGLE_NOISE_UNCORRELATE = 100;

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
  public InkLeakCanvas canvas;

  public Edge(InkLeakCanvas canvas, Node a, Node b) {
    this.canvas = canvas;
    this.nodeA = a;
    this.nodeB = b;
  }

  public void draw() {
    PVector pointA;
    PVector pointB;
    for (int i = 0; i < this.canvas.edge_times; i ++) {
      pointA = this.nodeA.sample();
      pointB = this.nodeB.sample();
      line(pointA.x, pointA.y, pointB.x, pointB.y);
    }
    if (this.canvas.do_border) {
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
  public int edge_times = 1;
  public boolean do_border = true;

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
    Edge edge = new Edge(this, a, b);
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

void echoClear(float density, int x1, int y1, int x2, int y2) {
  int w = x2 - x1;
  int h = y2 - y1;
  int times = (int) ((float) abs(h) * density);
  for (int i = 0; i < times; i ++) {
    line(
      random(w) + x1, 
      random(h) + y1, 
      random(w) + x1, 
      random(h) + y1
      );
  }
}

void echoClear(float density) {
  echoClear(density, 0, 0, width, height);
}

void echoClear(String mode) {
  float density;
  if (mode.equals("low")) {
    density = .015;
  } else if (mode.equals("mid")) {
    density = .15;
  } else if (mode.equals("high")) {
    density = .25;
  } else {
    density = .15;
    println("Warning: echoClear input mismatch");
  }
  echoClear(density, 0, 0, width, height);
}

