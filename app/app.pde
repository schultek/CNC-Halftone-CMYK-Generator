/* KEYS
enter: prerender image
backspace: back to setup
w,a,s,d: move image
q,e: scale image
y, x, c, v: num of lines
left, right: distance between lines
+, -: size of milling-bit
l, j, i, k: size of border
up, down: steps per line (for dotted images choose a low number and set "dotted = true"
p: print gcode
f: show overlap of lines
z: export settings
t: inport settings
1, 2, 3, 4, 5: change color-mode
TAB: toggle color layers
o: save screen as image
*/

//uncomment following line for dotted rendering
//boolean dotted = true;
//uncomment folliwing line for line rendering
boolean dotted = false;

//set dimensions of your pen
float penW = 3.125; //widest diameter (mm)
float penH = 4.9; //height between apex of the cone and place of widest diameter (mm)
float penMin = 0.15; //diameter at apex of the cone (mm)

//set dimensions of your sheet
float sheetW = 300; // width of sheet (mm)
float sheetH = 200; // height of sheet (mm)
float borderW = 20; // width of border (mm)
float borderH = 20; // height of border (mm)




PImage image;
int colorMode = 1;
int[] linesL = {10, 10, 10, 10};
int[] linesR = {10, 10, 10, 10};
float[] distance = {4, 4, 4, 4};
ArrayList<ArrayList<Point>> avgsC = new ArrayList<ArrayList<Point>>();
ArrayList<ArrayList<Point>> avgsM = new ArrayList<ArrayList<Point>>();
ArrayList<ArrayList<Point>> avgsY = new ArrayList<ArrayList<Point>>();
ArrayList<ArrayList<Point>> avgsK = new ArrayList<ArrayList<Point>>();
int[] steps = {200, 200, 200, 200};
float[] maxRad = {3.1, 3.1, 3.1, 3.1};
float[] angle = {0, 0, 0, 0};
boolean aH = false;
boolean render = false;
float imgW;
float imgF = 1;
float imgX = 0;
float imgY = 0;
boolean imgHo = false;
float[] ms = {0,0};
float scF;
float sheetX;
float sheetY;
float hOut = 2.0;
Point[][] curve = {new Point[4], new Point[4], new Point[4], new Point[4]};
boolean showAll = false;

boolean save = false;
String savePath;

void keyPressed() {
  if (key == CODED) {
    switch(keyCode) {
    case UP:
      if (colorMode == 1) {
        steps[0]++; 
        steps[1]++; 
        steps[2]++; 
        steps[3]++;
      } else {
        steps[colorMode - 2]++;
      }
      break;
    case DOWN: 
      if (colorMode == 1) {
        steps[0]--; 
        steps[1]--; 
        steps[2]--;
        steps[3]--;  
      } else {
        steps[colorMode - 2]--;
      }
      break;
    case LEFT:
      if (colorMode == 1) {
        distance[0] -= 0.1; 
        distance[1] -= 0.1; 
        distance[2] -= 0.1; 
        distance[3] -= 0.1; 
      } else {
        distance[colorMode - 2] -= 0.1;
      }
      break;
    case RIGHT:
      if (colorMode == 1) {
        distance[0] += 0.1; 
        distance[1] += 0.1; 
        distance[2] += 0.1; 
        distance[3] += 0.1; 
      } else {
        distance[colorMode - 2] += 0.1;
      }
      break;
    }
    if (render) {
      imgFilter();
    }
  } else {
    if (key == '1') {
      colorMode = 1;
    }
    if (key == '2') {
      colorMode = 2;
    }
    if (key == '3') {
      colorMode = 3;
    }
    if (key == '4') {
      colorMode = 4;
    }
    if (key == '5') {
      colorMode = 5;
    }
    if (key == '+') {
      if (colorMode == 1) {
        maxRad[0] += 0.1; 
        maxRad[1] += 0.1; 
        maxRad[2] += 0.1; 
        maxRad[3] += 0.1; 
      } else {
        maxRad[colorMode - 2] += 0.1;
      }
      if (maxRad[0] > penW) {
        maxRad[0] = penW;
      }
      if (maxRad[1] > penW) {
        maxRad[1] = penW;
      }
      if (maxRad[2] > penW) {
        maxRad[2] = penW;
      }
      if (maxRad[3] > penW) {
        maxRad[3] = penW; 
      }
    }
    if (key == '-') {
      if (colorMode == 1) {
        maxRad[0] -= 0.1; 
        maxRad[1] -= 0.1; 
        maxRad[2] -= 0.1; 
        maxRad[3] -= 0.1; 
      } else {
        maxRad[colorMode - 2] -= 0.1;
      }
      if (maxRad[0] < 0) {
        maxRad[0] = 0;
      }
      if (maxRad[1] < 0) {
        maxRad[1] = 0;
      }
      if (maxRad[2] < 0) {
        maxRad[2] = 0;
      }
      if (maxRad[3] < 0) {
        maxRad[3] = 0;
      }
    }
    if (key == 'w') {
      imgY--;
    }
    if (key == 's') {
      imgY++;
    }
    if (key == 'a') {
      imgX--;
    }
    if (key == 'd') {
      imgX++;
    }
    if (key == 'q') {
      imgW-=5;
    }
    if (key == 'e') {
      imgW+=5;
    }
    if (key == 'l') {
      borderW++;
    }
    if (key == 'j') {
      borderW++;
    }
    if (key == 'i') {
      borderH++;
    }
    if (key == 'k') {
      borderH--;
    }
    if (key == 'y') {
      if (colorMode == 1) {
        linesL[0]++; 
        linesL[1]++; 
        linesL[2]++; 
        linesL[3]++; 
      } else {
        linesL[colorMode - 2]++;
      }
    }
    if (key == 'x') {
      if (colorMode == 1) {
        linesL[0]--; 
        linesL[1]--; 
        linesL[2]--;  
        linesL[3]--; 
      } else {
        linesL[colorMode - 2]--;
      }
    }
    if (key == 'c') {
      if (colorMode == 1) {
        linesR[0]--; 
        linesR[1]--; 
        linesR[2]--; 
        linesR[3]--; 
      } else {
        linesR[colorMode - 2]--;
      }
    }
    if (key == 'v') {
      if (colorMode == 1) {
        linesR[0]++; 
        linesR[1]++; 
        linesR[2]++; 
        linesR[3]++; 
      } else {
        linesR[colorMode - 2]++;
      }
    }
    if (key == 'p') {
      selectOutput("Select a file to write to:", "printGcode");
    }
    if (key == 'z') {
      selectOutput("Select a file to write to:", "saveProject");
    }
    if (key == 't') {
      selectInput("Select a file to import:", "openProject");
    }
    if (key == 'o') {
      selectOutput("Select a file to write to:", "saveImage");
    }
    if (key == ENTER) {
      render = true;
    }
    if (key == BACKSPACE) {
      render = false;
    }
    if (key == TAB) {
      showAll = !showAll;
    }
    
    if (render) {
      imgFilter();
    }
  }
}


void setup() {
  size(1700, 800);
  for (int i = 0; i < 4; i++) {
    curve[i][0] = new Point(sheetW/2-20, sheetH/2-20);
    curve[i][1] = new Point(sheetW/2-10, 5);
    curve[i][2] = new Point(sheetW/2+10, sheetH-5);
    curve[i][3] = new Point(sheetW/2+20, sheetH/2+20);
  }

  scF = min((float)width/sheetW, (float)height/sheetH);
  sheetX = ((width/scF)-sheetW)/2;
  sheetY = ((height/scF)-sheetH)/2;
  
  if (dotted) {
    hOut = 0.7;
  }
  selectInput("Select a file to process:", "fileSelected");
}

void draw() {
  background(255);
  translate(sheetX*scF,sheetY*scF);
  
  if (!render && image != null) {
    image(image, imgX*scF, imgY*scF, imgW*scF, imgW*scF*imgF);
  }
   
  if (render) {
    
    noStroke();
    
    if (showAll || colorMode == 2 || colorMode == 1) {
      fill(0, 255, 255, 85);
      for (int i = 0; i < avgsC.size(); i++) {
        for (int j = 0; j < avgsC.get(i).size(); j++) {
          ellipse(avgsC.get(i).get(j).x*scF, avgsC.get(i).get(j).y*scF, avgsC.get(i).get(j).data*scF, avgsC.get(i).get(j).data*scF);
        }
      }
    }
    if (showAll || colorMode == 3 || colorMode == 1) {    
      fill(255, 0, 255, 85);
      for (int i = 0; i < avgsM.size(); i++) {
        for (int j = 0; j < avgsM.get(i).size(); j++) {
          ellipse(avgsM.get(i).get(j).x*scF, avgsM.get(i).get(j).y*scF, avgsM.get(i).get(j).data*scF, avgsM.get(i).get(j).data*scF);
        }
      }
    }
    if (showAll || colorMode == 4 || colorMode == 1) {
      fill(255, 255, 0, 85);
      for (int i = 0; i < avgsY.size(); i++) {
        for (int j = 0; j < avgsY.get(i).size(); j++) {
          ellipse(avgsY.get(i).get(j).x*scF, avgsY.get(i).get(j).y*scF, avgsY.get(i).get(j).data*scF, avgsY.get(i).get(j).data*scF);
        }
      }
    }
    if (showAll || colorMode == 5 || colorMode == 1) {
      fill(0, 0, 0, 85);
      for (int i = 0; i < avgsK.size(); i++) {
        for (int j = 0; j < avgsK.get(i).size(); j++) {
          ellipse(avgsK.get(i).get(j).x*scF, avgsK.get(i).get(j).y*scF, avgsK.get(i).get(j).data*scF, avgsK.get(i).get(j).data*scF);
        }
      }
    }
  }

  fill(255);
  noStroke();
  rect(0,0,(int)borderW*scF/2, height);
  rect(0,0,width, (int)borderH*scF/2);
  rect(width-(borderW*scF/2),0,(int)borderW*scF/2, height);
  rect(0,height-(borderH*scF/2),width, (int)borderH*scF/2);
  
  if (!save) {
    translate(-sheetX*scF,-sheetY*scF);
    fill(30);
    rect(0,0,sheetX*scF,height);
    rect(0,0,width,sheetY*scF);
    rect(0,height-sheetY*scF,width,sheetY*scF);
    rect(width-sheetX*scF,0,sheetX*scF,height);
  }
  
  translate(sheetX*scF,sheetY*scF);
  if (!render && !save) {
    if (colorMode != 1) {
      noFill();
      if (colorMode == 2) {
        stroke(0, 255, 255);
      }
      if (colorMode == 3) {
        stroke(255, 0, 255);
      }
      if (colorMode == 4) {
        stroke(255, 255, 0);
      }
      if (colorMode == 5) {
        stroke(0, 0, 0);
      }
      int md = colorMode - 2;
      beginShape();
      vertex(curve[md][1].x*scF, curve[md][1].y*scF);
      bezierVertex(curve[md][0].x*scF,curve[md][0].y*scF,curve[md][3].x*scF,curve[md][3].y*scF,curve[md][2].x*scF,curve[md][2].y*scF);
      endShape();
     
      curve[md][0].draw(scF);
      curve[md][1].draw(scF);
      curve[md][2].draw(scF);
      curve[md][3].draw(scF);
      
      float mx = curve[md][1].x + (curve[md][2].x - curve[md][1].x)/2;
      float my = curve[md][1].y + (curve[md][2].y - curve[md][1].y)/2;
      ellipse(mx*scF, my*scF, 50, 50);
      line(mx*scF, my*scF, mx*scF + (cos(radians(angle[md]))*25), my*scF - (sin(radians(angle[md]))*25));
    }
   
  } else {
    if (!save) {
      stroke(0);
      fill(0);
      //text(minFree,5,10);
      text(steps[0],50,10);
      text(linesL[0]+linesR[0], 90, 10);
      text(distance[0],130,10);
      text(maxRad[0], 170,10);
      
      text(steps[1],230,10);
      text(linesL[1]+linesR[1], 270, 10);
      text(distance[1],310,10);
      text(maxRad[1], 350,10);
      
      text(steps[2],410,10);
      text(linesL[2]+linesR[2], 450, 10);
      text(distance[2],490,10);
      text(maxRad[2], 530,10);
      
      text(steps[3],590,10);
      text(linesL[3]+linesR[3], 630, 10);
      text(distance[3],670,10);
      text(maxRad[3], 710,10);
    }
  }
  translate(-sheetX*scF,-sheetY*scF);
  
  if (save) {
    save = false;
    save(savePath);
  }
}

void imgFilter() {
  if (colorMode == 1 || colorMode == 2) {
    imgFilter(avgsC, 0);
  }
  if (colorMode == 1 || colorMode == 3) {
    imgFilter(avgsM, 1);
  }
  if (colorMode == 1 || colorMode == 4) {
    imgFilter(avgsY, 2);
  }
  if (colorMode == 1 || colorMode == 5) {
    imgFilter(avgsK, 3);
  }
}

void imgFilter(ArrayList<ArrayList<Point>> array, int mode) {
  array.clear();
  array.add(new ArrayList<Point>());
  for (float i = 0; i <= 1; i += (float)1/steps[mode]) {
    Point p = getCurvePoint(i, mode);
    array.get(0).add(new Point(p.x, p.y, getAVG(p, mode)));
  }
  for (int i = 1; i < linesR[mode]; i++) {
    float offsetx = i*distance[mode]*cos(radians(angle[mode]));
    float offsety = i*distance[mode]*(-sin(radians(angle[mode])));
    array.add(new ArrayList<Point>());
    for (float j = 0; j <= 1; j += (float)1/steps[mode]) {
      Point p = getCurvePoint(j, mode);
      Point p1 = new Point(p.x+offsetx, p.y+offsety);
      if (p1.x > 0 && p1.x < width && p1.y > 0 && p1.y < height) {
        array.get(array.size()-1).add(new Point(p1.x, p1.y, getAVG(p1, mode)));
      }
    }
  }
  for (int i = 1; i < linesL[mode]; i++) {
    float offsetx = i*distance[mode]*cos(radians(angle[mode]));
    float offsety = i*distance[mode]*(-sin(radians(angle[mode])));
    array.add(0, new ArrayList<Point>());
    for (float j = 0; j <= 1; j += (float)1/steps[mode]) {
      Point p = getCurvePoint(j, mode);
      Point p2 = new Point(p.x-offsetx, p.y-offsety);
      if (p2.x > 0 && p2.x < width && p2.y > 0 && p2.y < height) {
        array.get(0).add(new Point(p2.x, p2.y, getAVG(p2, mode)));
      }
    }
  }
}

float getAVG(Point p, int mode) {
  float sum = 0;
  float count = 0;
  float rad = maxRad[mode]/2;
  float factor = image.width/imgW;
  image.loadPixels();
  for (int x = (int)(p.x*factor - rad*factor - imgX*factor); x < p.x*factor + rad*factor - imgX*factor; x += 1) {
    if (x < 0 || x >= image.width) { 
      continue;
    }
    for (int y = (int)(p.y*factor -rad*factor -imgY*factor); y<p.y*factor +rad*factor -imgY*factor; y += 1) {
      if (y < 0 || y >= image.height) { 
        continue;
      }
      float r = red(image.pixels[y*image.width+x]);
      float g = green(image.pixels[y*image.width+x]);
      float b = blue(image.pixels[y*image.width+x]);
      float k = 1-max(r/255,g/255,b/255);
      float c = (1-(r/255)-k)/(1-k);
      float m = (1-(g/255)-k)/(1-k);
      float ye = (1-(b/255)-k)/(1-k);
      if (mode == 0) {
        sum += c;
      }
      if (mode == 1) {
        sum += m;
      }
      if (mode == 2) {
        sum += ye;
      }
      if (mode == 3) {
        sum += k;
      }
      count+=1;
    }
  }
  image.updatePixels();
  
  float data = (sum / count)*maxRad[mode];
  if (data < penMin) {data = 0;}
  return data;
}


Point getCurvePoint(float f, int mode) {  

  float xa = curve[mode][1].x + (f * (curve[mode][0].x - curve[mode][1].x));
  float ya = curve[mode][1].y + (f * (curve[mode][0].y - curve[mode][1].y));
  float xb = curve[mode][0].x + (f * (curve[mode][3].x - curve[mode][0].x));
  float yb = curve[mode][0].y + (f * (curve[mode][3].y - curve[mode][0].y));
  float xc = curve[mode][3].x + (f * (curve[mode][2].x - curve[mode][3].x));
  float yc = curve[mode][3].y + (f * (curve[mode][2].y - curve[mode][3].y));

  float xab = xa + (f * (xb - xa));
  float yab = ya + (f * (yb - ya));
  float xbc = xb + (f * (xc - xb));
  float ybc = yb + (f * (yc - yb));

  float xabc = xab + (f * (xbc - xab));
  float yabc = yab + (f * (ybc - yab));

  return new Point(xabc, yabc);
}

void printGcode(File selection) {
  if (selection == null) {
    return;
  }
  String path = selection.getAbsolutePath();
  selection.mkdir();
  saveStrings(path+"/"+selection.getName()+"-cyan.nc", getGCode(avgsC, 0));
  saveStrings(path+"/"+selection.getName()+"-magenta.nc", getGCode(avgsM, 1));
  saveStrings(path+"/"+selection.getName()+"-yellow.nc", getGCode(avgsY, 2));
  saveStrings(path+"/"+selection.getName()+"-black.nc", getGCode(avgsK, 3));
}

String[] getGCode(ArrayList<ArrayList<Point>> array, int mode) {
  ArrayList<String> output = new ArrayList<String>();
  boolean in = false;
  output.add("G92 X0 Y0 Z0");
  output.add("G21");
  output.add("G90");
  output.add("G1 Z5.0");
  for (int i = 0; i < array.size(); i++) {
    for (int j = 0; j < array.get(i).size(); j++) {
      Point p = new Point(array.get(i).get(j).x, array.get(i).get(j).y, array.get(i).get(j).data);
      p.y = sheetH-p.y;
      if (p.x < borderW/2 || p.x > sheetW-(borderW/2) || p.y < borderH/2 || p.y > sheetH-(borderH/2)) {
        if (in) {
          output.add("G1 Z"+hOut);
          in = false;
        }
        continue;
      }
      if (dotted) {
        if (p.data > 0) {
          output.add("G0 X"+p.x+" Y"+p.y);
          output.add("G1 Z"+(-(p.data/penW)*penH));
          output.add("G1 Z"+hOut);
        }
      } else {
        if (in) {
          if (p.data > 0) {
            output.add("G1 X"+p.x+" Y"+p.y+" Z"+(-(p.data/penW)*penH));
          } else {
            output.add("G1 Z"+hOut);
            in = false;
          }
        } else {
          if (p.data > 0) {
            output.add("G0 X"+p.x+" Y"+p.y);
            output.add("G1 Z"+(-(p.data/penW)*penH));
            in = true;
          }
        }
      }
    }
    if (in) {
      output.add("G1 Z"+hOut);
      in = false;
    }
  }
  if (in) {
    output.add("G1 Z"+hOut);
    in = false;
  }
  output.add("G0 X0.000 Y0.000");
  output.add("G0 Z0.000");
  return output.toArray(new String[output.size()]);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    String file = selection.getAbsolutePath();
    println(file.substring(file.length()-4));
    if (file.substring(file.length()-4).equals(".kik")) {
      openProject(selection);
    } else {
      image = loadImage(file);
      imgW = sheetW;
      imgF = (float)image.height/image.width;
    }
  }
}

void saveProject(File selection) {
  fill(0);
  rect(0, 0, width, height);
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return;
  }
  ArrayList<String> output = new ArrayList<String>();
  for (int i = 0; i < 4; i++) {
    output.add(str(linesL[i]));
    output.add(str(linesR[i]));
    output.add(str(distance[i]));
    output.add(str(steps[i]));
    output.add(str(maxRad[i]));
    output.add(str(angle[i]));
    output.add(str(curve[i][0].x));
    output.add(str(curve[i][0].y));
    output.add(str(curve[i][1].x));
    output.add(str(curve[i][1].y));
    output.add(str(curve[i][2].x));
    output.add(str(curve[i][2].y));
    output.add(str(curve[i][3].x));
    output.add(str(curve[i][3].y));  
  }
  output.add(str(dotted));
  output.add(str(sheetW));
  output.add(str(sheetH));
  output.add(str(sheetX));
  output.add(str(sheetY));
  output.add(str(penW));
  output.add(str(penH));
  output.add(str(penMin));
  output.add(str(borderW));
  output.add(str(borderH));
  output.add(str(hOut));
  output.add(str(colorMode));
  output.add(str(imgW));
  output.add(str(imgF));
  output.add(str(imgX));
  output.add(str(imgY));
  output.add(str(scF));
  output.add(str(image.width));
  output.add(str(image.height));
  output.add(imageToString());
  println("Saving Project... ("+output.size()+" lines)");
  String[] settings = output.toArray(new String[output.size()]);
  saveStrings(selection.getAbsolutePath(), settings);
  fill(255);
  rect(0,0,width,height);
}

String imageToString() {
  ArrayList<String> out = new ArrayList<String>();
  image.loadPixels();
  for (int i = 0; i < image.pixels.length; i++) {
    out.add(str(image.pixels[i]));
  }
  String[] imgstr = out.toArray(new String[out.size()]);
  return join(imgstr, ":");
}


void openProject(File selection) {
  String[] settings = loadStrings(selection.getAbsolutePath());
  for (int i = 0; i < 4; i++) {
    linesL[i] = Integer.parseInt(settings[i*14]);
    linesR[i] = Integer.parseInt(settings[i*14+1]);
    distance[i] = Float.parseFloat(settings[i*14+2]);
    steps[i] = Integer.parseInt(settings[i*14+3]);
    maxRad[i] = Float.parseFloat(settings[i*14+4]);
    angle[i] = Float.parseFloat(settings[i*14+5]);
    curve[i][0].x = Float.parseFloat(settings[i*14+6]);
    curve[i][0].y = Float.parseFloat(settings[i*14+7]);
    curve[i][1].x = Float.parseFloat(settings[i*14+8]);
    curve[i][1].y = Float.parseFloat(settings[i*14+9]);
    curve[i][2].x = Float.parseFloat(settings[i*14+10]);
    curve[i][2].y = Float.parseFloat(settings[i*14+11]);
    curve[i][3].x = Float.parseFloat(settings[i*14+12]);
    curve[i][3].y = Float.parseFloat(settings[i*14+13]);
  }
  dotted = Boolean.parseBoolean(settings[56]);
  sheetW = Float.parseFloat(settings[57]);
  sheetH = Float.parseFloat(settings[58]);
  sheetX = Float.parseFloat(settings[59]);
  sheetY = Float.parseFloat(settings[60]);
  penW = Float.parseFloat(settings[61]);
  penH = Float.parseFloat(settings[62]);
  penMin = Float.parseFloat(settings[63]);
  borderW = Float.parseFloat(settings[64]);
  borderH = Float.parseFloat(settings[65]);
  hOut = Float.parseFloat(settings[66]);
  
  imgW = Float.parseFloat(settings[68]);
  imgF = Float.parseFloat(settings[69]);
  imgX = Float.parseFloat(settings[70]);
  imgY = Float.parseFloat(settings[71]);
  scF = Float.parseFloat(settings[72]);
  imageFromString(Integer.parseInt(settings[73]), Integer.parseInt(settings[74]), settings[75]);
  
  colorMode = 1;
  showAll = true;
  render = true;
  imgFilter();
  colorMode = Integer.parseInt(settings[67]);
  
}

void imageFromString(int w, int h, String imgstr) {
  String[] cstr = imgstr.split(":");
  image = createImage(w, h, RGB);
  println(Integer.parseInt(cstr[100]));
  println(color(Integer.parseInt(cstr[100])));
  image.loadPixels();
  for (int i = 0; i < image.pixels.length; i++) {
    image.pixels[i] = color(Integer.parseInt(cstr[i]));
  }
  println(image.pixels[100]);
  image.updatePixels();
}

void saveImage(File selection) {
  /*PImage screen = createImage((int)(sheetW*scF), (int)(sheetH*scF), RGB);
  draw();
  screen.loadPixels();
  loadPixels();
  for (int x = 0; x < sheetW*scF; x++) {
    for (int y = 0; y < sheetH*scF; y++) {
      screen.pixels[y*screen.width+x] = pixels[(int)sheetX+x+y*width+(int)sheetY*width];
    }
  }
  updatePixels();
  screen.updatePixels();
  screen.save(selection.getAbsolutePath());
  */
  save = true;
  savePath = selection.getAbsolutePath();
}

void mouseMoved() {
  int refX = (int)((mouseX/scF)-sheetX);
  int refY = (int)((mouseY/scF)-sheetY);
  if (colorMode != 1) {
    for (int i = 0; i < 4; i++) {
      if (curve[colorMode - 2][i].hover(refX, refY)) {
        return;
      }
    }
    float mx = curve[colorMode - 2][1].x + (curve[colorMode - 2][2].x - curve[colorMode - 2][1].x)/2;
    float my = curve[colorMode - 2][1].y + (curve[colorMode - 2][2].y - curve[colorMode - 2][1].y)/2;
    if (refX > mx - 10 && refX < mx + 10 && refY > my - 10 && refY < my + 10) {
      aH = true;
      return;
    } else {
      aH = false;
    }
  }
  
  if (refX > imgX && refX < imgX + imgW*scF && refY > imgY && refY < imgY + (imgW*imgF*scF)) {
    imgHo = true;
    ms[0] = refX;
    ms[1] = refY;
    return;
  } else {
    imgHo = false;
  }
}

void mouseDragged() {
  int refX = (int)((mouseX/scF)-sheetX);
  int refY = (int)((mouseY/scF)-sheetY);
  if (colorMode != 1) {
    for (int i = 0; i < 4; i++) {
      if (curve[colorMode - 2][i].press(refX, refY)) {
        //imgFilter();
        return;
      }
    }
    float mx = curve[colorMode - 2][1].x + (curve[colorMode - 2][2].x - curve[colorMode - 2][1].x)/2;
    float my = curve[colorMode - 2][1].y + (curve[colorMode - 2][2].y - curve[colorMode - 2][1].y)/2;
    if (aH) {
      float r = sqrt(sq(mx - refX) + sq(my - refY));
      if (refY - my > 0) { 
        angle[colorMode - 2] = degrees(acos((float)(refX - mx)/(-r))) + 180;
      } else {
        angle[colorMode - 2] = degrees(acos((float)(refX - mx)/r));
      }
      return;
      //imgFilter();
    }
  }
  if (imgHo) {
    imgX += refX - ms[0];
    imgY += refY - ms[1];
    ms[0] = refX;
    ms[1] = refY;
    return;
  }
}

public class Point {

  public float x, y, data;
  public boolean hovered;
  public int size = 10;

  public Point(float xPos, float yPos) {
    x = xPos;
    y = yPos;
    hovered = false;
  }

  public Point(float xPos, float yPos, float d) {
    this(xPos, yPos);
    data = d;
  }

  public void draw() {
    noFill();
    ellipse(x, y, size, size);
  }
  
  public void draw(float scale) {
    noFill();
    ellipse(x*scale, y*scale, size, size);
  }

  public boolean press(int mx, int my) {
    if (hovered) {
      x = mx;
      y = my;
      return true;
    } else {
      return false;
    }
  }

  public boolean hover(int mx, int my) {
    if (mx > x-(size/scF/2) && mx < x+(size/scF/2) && my > y-(size/scF/2) && my < y+(size/scF/2)) {
      hovered = true;
      size = 20;
    } else {
      hovered = false;
      size = 10;
    }
    return hovered;
  }
}