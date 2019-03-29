Timer timer;
int i = 0;

void setup() {
    timer = new Timer();
}

void draw() {
    while (timer.spin(1000)) {
        println(i);
        i ++; 
    }
    if (i == 4) {
        delay(2000);
    }
}
