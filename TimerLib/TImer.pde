class Timer {
    public int time;
    
    public Timer() {
        this.setNow();
    }
    
    public void setNow() {
        this.time = millis();
    }
    
    public void addMil(int x) { // supports negatives
        this.mil += x;
        int s = this.mil / 1000;
        if (s != 0) {
            this.mil -= s * 1000;
            this.addS(s);
        }
    }
    
    public void addS(int x) { // supports negatives
        this.s += x;
        int m = this.s / 60;
        if (m != 0) {
            this.s -= s * 60;
            this.addM(m);
        }
    }
    
    public void addM(int x) { // supports negatives
        this.m += x;
        int h = this.m / 60;
        if (h != 0) {
            this.m -= m * 60;
            this.addH(h);
        }
    }
    
    public void addH(int x) { // supports negatives
        this.h += x;
        this.h %= 24;
    }
    
    public boolean spin(int mil) {
        // do something like while(timer.spin(16))
        int delta = new Timer().sub(this);
        if (delta >= mil) {
            this.addMil(mil);
            println(millis());
            return true;
        }
        return false;
    }
}
