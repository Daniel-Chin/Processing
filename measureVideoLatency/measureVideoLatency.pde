import processing.serial.*;
import java.util.*;

Serial serial;

void setup() {
    size(500, 500);
    serial = new Serial(
        this, "COM3", 9600 * 4
    );
    // delay(1000);
    serial.clear();

    // testSelfRTT();
}
void testSelfRTT() {
    while (true) {
        int i = floor(random(126) + 1);
        // println("sending " + str(i) + "...");
        char c = (char) i;
        int start = millis();
        serial.write(c);
        while (serial.available() == 0) {
            print("");  
            /* 
            if no instruction is here, Processing doesn't even 
            yield and serial is never available. 
            */
        }
        char got = serial.readChar();
        if (got == c) {
            int stop = millis();
            println(stop - start);
        } else {
            println("got " + str((int)got));
        }
        // delay(500);
    }
}

final static int Q_SIZE = 32;
ArrayDeque<Integer> q = new ArrayDeque<Integer>(Q_SIZE);
int sec;
void draw() {
    int _sec = millis() / 1000;
    if (sec != _sec) {
        sec = _sec;
        serial.write('!');
    }
    if (sec % 2 == 0) {
        background(0);
    } else {
        background(255);
    }
    fill(128);
    textSize(128);
    text(millis() % 1000, 100, 200);
    text(frameRate, 0, 350);

    q.add(millis());
    if (q.size() == Q_SIZE) {
        int t0 = q.pop();
        text((Q_SIZE - 1) * 1000 / (millis() - t0), 0, 500);
    }
}
