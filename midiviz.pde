
import themidibus.*;
import javax.sound.midi.MidiMessage;

MidiBus midiBus;
PShape bot;
int msgNum;
Animation animation1, animation2, animation3, animation4;
int width, height, centerX, centerY;
float thirty_deg = TWO_PI/12.0;
PImage img;

public void init() {
  frame.removeNotify();
  frame.setUndecorated(true);
  super.init();
} 

void setup() {
  img = loadImage("md-bg-v1.png");
  width = 1920/2;
  height = 1080/2;
  centerX = width/2;
  centerY = height/2;
  size(width, height, OPENGL);
  // The file "bot1.svg" must be in the data folder
  // of the current sketch to load successfully
  msgNum = 0;
  bot = loadShape("test.svg");
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  midiBus = new MidiBus(this, 1, 2); // Create a new MidiBus object
  frameRate(30);
  animation1 = new KickAnimation(15);
  animation2 = new SnareAnimation(15);
  animation3 = new HiHatAnimation(15);
  noFill();
} 

void draw(){
  frame.setLocation(20, 20);
  //frame.setAlwaysOnTop(true);
  background(0);
  stroke(255);
  image(img, 0, 0);
  animation1.display();
  animation2.display();
  animation3.display();
}

void polygon(float x, float y, float radius, int npoints, float rotate) {
  float angle = (TWO_PI / npoints);
  beginShape();
  for (float a = rotate; a < TWO_PI + rotate; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  // Receive a MidiMessage
  // MidiMessage is an abstract class, the actual passed object will be either javax.sound.midi.MetaMessage, javax.sound.midi.ShortMessage, javax.sound.midi.SysexMessage.
  // Check it out here http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
  
  if(message.getStatus() == 144) {
	  msgNum++;
    println();
	  println("MidiMessage " + msgNum + " Data:");
	  println("--------");
    int param1 = (int)(message.getMessage()[1] & 0xFF);
  	int param2 = (int)(message.getMessage()[1] & 0xFF);
    println("Status Byte/MIDI Command: " +message.getStatus() + " ("+ param1 + " " +param2+ ")");  
    switch(param1) {
      case 64: animation3.trigger(); break;
      case 65: animation2.trigger(); break;
      case 66: animation1.trigger(); break;
      case 67: animation1.trigger(); break;
      default: println("Unknown MIDI note: "+ param1); break;  
    }
  }
}

abstract class Animation {
  int frameCount;
  int frame;
  
  Animation(int count) {
    frameCount = count;
    frame = count;
  }

  void display() {
  	if (frame >= frameCount) { 
      return;
    } 
  	
    drawFrame();
    frame++;

    if (frame >= frameCount) { 
      println("Animation Ended!");
    }
  }

  abstract void drawFrame();

  void trigger() {
  	println("Triggering Animation!");
  	frame = 0;
  }
}

class SnareAnimation extends Animation {
  
  SnareAnimation(int i) {
    super(i);
  }

  void drawFrame() {
    strokeWeight(frameCount - frame);
    polygon(centerX, centerY, width/5, 3, -thirty_deg);
  }
}

class KickAnimation extends Animation {
   KickAnimation(int i) {
    super(i);
  }

  void drawFrame() {
   strokeWeight(frameCount - frame);
   polygon(centerX, centerY, width/4, 6, thirty_deg); 
  }
}

class HiHatAnimation extends Animation {
   HiHatAnimation(int i) {
    super(i);
  }

  void drawFrame() {
    strokeWeight(frameCount - frame);
    ellipse(centerX, centerY, width/7, width/7);
  }
}
