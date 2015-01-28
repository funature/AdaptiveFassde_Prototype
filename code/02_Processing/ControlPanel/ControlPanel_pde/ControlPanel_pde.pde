import processing.serial.*;
import java.util.Date;
import controlP5.*;

Serial mySerial;
int lf = 10;    // Linefeed in ASCII
String myString = null;
PrintWriter output;
PGraphics pg;
ControlP5 controlP5;
int messageBoxResult = -1;
ControlGroup messageBox;

void setup() {
  size(600, 400);
  background(100);
  pg = createGraphics(600, 400);
  frameRate(30);
  mySerial = new Serial( this, "COM4", 9600 );

  controlP5 = new ControlP5(this);
  createMessageBox();
  messageBox.hide();

  mySerial.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = mySerial.readStringUntil(lf);
  myString = null;

  Date d = new Date();

  int[] t = new int[7]; 

  //   int y = year();   // 2003, 2004, 2005, etc.
  //   int m = month();  // Values from 1 - 12
  //   int d = day();    // Values from 1 - 31
  //   int h = hour();
  //   int m = minute();
  //   int s = second();
  //   int mi = millis();

  t[0] = year();   // 2003, 2004, 2005, etc.
  t[1] = month();  // Values from 1 - 12
  t[2] = day();    // Values from 1 - 31
  t[3] = hour();
  t[4] = minute();
  t[5] = second();
  t[6] = millis();

  String tt = join(str(t), ".");

  long current = d.getTime()/1000;
  //   String filename = String.valueOf(current) + "_data.txt"; 
  String filename = tt + "_data.txt"; 
  output = createWriter( filename );
}
void draw() {
  pg.clear();
  pg.background(100);
  pg.beginDraw();

  pg.stroke(100);          // Setting the outline (stroke) to black
  pg.fill(50);  

  pg.rect(240, 170, 350, -45);
  pg.rect(240, 220, 350, -45);
  pg.rect(240, 270, 350, -45);
  pg.rect(240, 320, 350, -45);
  pg.rect(240, 370, 350, -45);


  pg.stroke(255);          // Setting the outline (stroke) to black
  pg.fill(255);  

  pg.textSize(18); 

  pg.text("Control Panel:", 20, 38); 

  pg.textSize(14); 

  pg.text("Timestamp:", 240, 38); 

  pg.text("rValue", 20, 150); 
  pg.text("Fan Power", 20, 200); 
  pg.text("RPM", 20, 250); 
  pg.text("Temp_Top", 20, 300); 
  pg.text("Temp_Bottom", 20, 350); 

  if (mySerial.available() > 0 ) {
    myString = mySerial.readStringUntil(lf);

    if ( myString  != null ) {

      myString.replace("C", "");
      output.print( myString );
      String[] list = split(myString, ',');
      pg.text(list[0], 330, 38); 
      pg.text(list[1], 140, 150); 
      pg.text(list[2] + " %", 140, 200); 
      pg.text(list[3], 140, 250); 
      pg.text(list[4], 140, 300); 
      pg.text(list[5], 140, 350);
    }
  }else{
      pg.text("no data", 330, 38); 
      pg.text("no data", 140, 150); 
      pg.text("no data" + " %", 140, 200); 
      pg.text("no data", 140, 250); 
      pg.text("no data", 140, 300); 
      pg.text("no data", 140, 350);
    
  }
  
  pg.endDraw();
  image(pg, 0, 0);
}


void createMessageBox() {
  // create and set a ControlFont, in case the
  // the default controlP5 font is too small for you / the user
  ControlFont font = new ControlFont(createFont("Arial", 12), 12);
  // if the size of controlP5's default pixel font is not
  // too small, disable the setControlFont command below.
  controlP5.setControlFont(font);

  // create a group to store the messageBox elements
  messageBox = controlP5.addGroup("messageBox", width/2 - 150, 100, 300);
  messageBox.setBackgroundHeight(120);
  messageBox.setBackgroundColor(color(0, 128));
  messageBox.hideBar();

  // add a TextLabel to the messageBox.
  Textlabel l = controlP5.addTextlabel("messageBoxLabel", "Are you sure to close the program?", 20, 20);
  l.moveTo(messageBox);

  // add the OK button to the messageBox.
  // the name of the button corresponds to function buttonOK
  // below and will be triggered when pressing the button.
  controlP5.Button b1 = controlP5.addButton("buttonOK", 0, 65, 80, 80, 24);
  b1.moveTo(messageBox);
  // by default setValue would trigger function buttonOK, 
  // therefore we disable the broadcasting before setting
  // the value and enable broadcasting again afterwards.
  // same applies to the cancel button below.
  b1.setBroadcast(false); 
  b1.setValue(1);
  b1.setBroadcast(true);
  b1.setCaptionLabel("Yes");
  // centering of a label needs to be done manually 
  // with marginTop and marginLeft
  b1.captionLabel().style().marginTop = -2;
  b1.captionLabel().style().marginLeft = 26;

  // add the Cancel button to the messageBox. 
  // the name of the button corresponds to function buttonCancel
  // below and will be triggered when pressing the button.
  controlP5.Button b2 = controlP5.addButton("buttonCancel", 0, 155, 80, 80, 24);
  b2.moveTo(messageBox);
  b2.setBroadcast(false);
  b2.setValue(0);
  b2.setBroadcast(true);
  b2.setCaptionLabel("Cancel");
  b2.captionLabel().toUpperCase(false);
  b2.captionLabel().style().marginTop = -2;
  b2.captionLabel().style().marginLeft = 16;
}

// function buttonOK will be triggered when pressing
// the OK button of the messageBox.
void buttonOK(int theValue) {
  //  println("a button event from button OK.");
  messageBoxResult = theValue;
  messageBox.hide();
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  exit();  // Stops the program
}
// function buttonCancel will be triggered when pressing
// the Cancel button of the messageBox.
void buttonCancel(int theValue) {
  //  println("a button event from button Cancel.");
  messageBoxResult = theValue;
  messageBox.hide();
}

void keyPressed() {
  messageBox.show();
} 

