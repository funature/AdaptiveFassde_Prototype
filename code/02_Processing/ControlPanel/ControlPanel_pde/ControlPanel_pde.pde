import processing.serial.*;
import java.util.Date;
import java.text.SimpleDateFormat;
import controlP5.*;
import grafica.*;

Serial mySerial;
int lf = 10;    // Linefeed in ASCII
String myString = null;
PrintWriter output;
PGraphics pg;
ControlP5 controlP5;
int messageBoxResult = -1;
ControlGroup messageBox;
int count = 0;

public GPlot plot1, plot2, plot3, plot4, plot5;

void setup() {
  size(600, 400);
  background(100);
  pg = createGraphics(600, 400);
  frameRate(30);
  mySerial = new Serial( this, "COM5", 9600 );

  controlP5 = new ControlP5(this);
  createMessageBox();
  messageBox.hide();


  // Setup for the first plot
  plot1 = new GPlot(this);
  plot1.setPos(200, 120);
  plot1.setDim(380, 45);
  plot1.setMar(0, 0, 0, 0);
  plot1.setExpandLimFactor(0);
  //  plot1.setXLim(0, 99);
//  plot1.setYLim(0, 1500);
  //  plot1.getTitle().setText("Multiple layers plot");
  //  plot1.getXAxis().getAxisLabel().setText("Time");
  //  plot1.getYAxis().getAxisLabel().setText("noise (0.1 time)");
  //  plot1.setLogScale("xy");
  plot1.setLineColor(color(200, 200, 255));
  //  plot1.addLayer("layer 1", points1b);
  //  plot1.getLayer("layer 1").setLineColor(color(150, 150, 255));
  //  plot1.addLayer("layer 2", points1c);
  //  plot1.getLayer("layer 2").setLineColor(color(100, 100, 255));
  
  
  plot2 = new GPlot(this);
  plot2.setPos(200, 170);
  plot2.setDim(380, 45);
  plot2.setMar(0, 0, 0, 0);
  plot2.setExpandLimFactor(0);
  plot2.setLineColor(color(200, 200, 255));
  
  plot3 = new GPlot(this);
  plot3.setPos(200, 220);
  plot3.setDim(380, 45);
  plot3.setMar(0, 0, 0, 0);
  plot3.setExpandLimFactor(0);
  plot3.setLineColor(color(200, 200, 255));
  
  plot4 = new GPlot(this);
  plot4.setPos(200, 270);
  plot4.setDim(380, 45);
  plot4.setMar(0, 0, 0, 0);
  plot4.setExpandLimFactor(0);
  plot4.setLineColor(color(200, 200, 255));
  
  plot5 = new GPlot(this);
  plot5.setPos(200, 320);
  plot5.setDim(380, 45);
  plot5.setMar(0, 0, 0, 0);
  plot5.setExpandLimFactor(0);
  plot5.setLineColor(color(200, 200, 255));

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

  //   String filename = String.valueOf(current) + "_data.txt"; 
  String filename = tt + "_data.txt"; 
  output = createWriter( filename );
}
void draw() {

  Date d = new Date();

  long timestamp = d.getTime();

  String strDate = new SimpleDateFormat("yyyy-MM-dd").format(timestamp);
  String strTime = new SimpleDateFormat("hh:mm:ss").format(timestamp);

  pg.clear();
  pg.background(100);
  pg.beginDraw();

  pg.stroke(100);          // Setting the outline (stroke) to black
  pg.fill(50);  

//  pg.rect(240, 170, 350, -45);
//  pg.rect(240, 220, 350, -45);
//  pg.rect(240, 270, 350, -45);
//  pg.rect(240, 320, 350, -45);
//  pg.rect(240, 370, 350, -45);


  pg.stroke(255);          // Setting the outline (stroke) to black
  pg.fill(255);  

  pg.line(200, 165, 580, 165);
  pg.line(200, 215, 580, 215);
  pg.line(200, 265, 580, 265);
  pg.line(200, 315, 580, 315);
  pg.line(200, 365, 580, 365);

  pg.textSize(18); 

  pg.text("Monitoring Panel:", 20, 38); 

  pg.textSize(14); 

  pg.text("Timestamp:", 240, 38); 
  pg.text(strDate, 240, 58);
  pg.text(strTime, 340, 58);

  pg.text("rValue", 20, 150); 
  pg.text("Fan Power", 20, 200); 
  pg.text("RPM", 20, 250); 
  pg.text("Temp_Top", 20, 300); 
  pg.text("Temp_Bottom", 20, 350); 

  if (mySerial.available() > 0 ) {
    myString = mySerial.readStringUntil(lf);

    if ( myString  != null ) {

      myString.replace("C", "");
      output.print(strDate + ",\t" + strTime + ",\t"); 
//      println(strDate + ", " + strTime + ", ");
      output.print( myString );
      String[] list = {
        "NA", "NA", "NA", "NA", "NA", "NA"
      };
      String[] values = split(myString, ',');
      for (int i = 0; i < values.length; i++){
        if (values[i].length() != 0){
          list[i] = values[i];
        }
      }
      pg.text(list[0], 330, 38); 
      pg.text(list[1], 140, 150); 
      pg.text(list[2] + " %", 140, 200); 
      pg.text(list[3], 140, 250); 
      pg.text(list[4], 140, 300); 
      println(list[5]);
      pg.text(list[5], 140, 350);
      pg.endDraw();
      image(pg, 0, 0);
      
      plot1.addPoint(count, int(list[1].replaceAll("\\s","")));
      plot2.addPoint(count, int(list[2].replaceAll("\\s","")));
      plot3.addPoint(count, int(list[3].replaceAll("\\s","")));
      plot4.addPoint(count, int(list[4].replaceAll("\\s","")));
      plot5.addPoint(count, int(list[5].replaceAll("\\s","")));
      
      count++;
    }
  }

  // Draw the first plot
  plot1.beginDraw();
  //  plot1.drawBackground();
//  plot1.drawBox();
  //  plot1.drawXAxis();
  //  plot1.drawYAxis();
  //  plot1.drawTopAxis();
  //  plot1.drawRightAxis();
  //  plot1.drawTitle();
  plot1.drawLines();
  plot1.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  //  plot1.drawPoint(new GPoint(65, 1.5), mug);
  //  plot1.drawPolygon(polygonPoints, color(255, 200));
  //  plot1.drawLabels();
  plot1.endDraw();
  
  plot2.beginDraw();
  plot2.drawLines();
  plot2.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  plot2.endDraw();
  
  plot3.beginDraw();
  plot3.drawLines();
  plot3.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  plot3.endDraw();
  
  plot4.beginDraw();
  plot4.drawLines();
  plot4.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  plot4.endDraw();
  
  plot5.beginDraw();
  plot5.drawLines();
  plot5.drawFilledContours(GPlot.HORIZONTAL, 0.05);
  plot5.endDraw();
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

void exit(){
  
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  super.exit();  // Stops the program
}

