class Timer {
    public int time;
    
    public Timer() {
        this.setNow();
    }
    
    public void setNow() {
        this.time = millis();
    }
    
    public boolean spin(int mil) {
        // do something like while(timer.spin(16))
        int delta = millis() - this.time;
        if (delta >= mil) {
            this.time += mil;
            return true;
        }
        return false;
    }
}
