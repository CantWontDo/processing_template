// This is preferable for situations when you want to
// have a [-a,a] range for an input value without having to remap
// the built-in noise() function.
// Can also take four inputs instead of three and has generally smoother
// outputs for organic shapes.
// NOTE: It's kind of annoying but all the outputs are doubles so you have to convert
//       to float before hand. Also there isn't a 1D function so you have to use a 
//       constant as one input to pin it in one dimension.
OpenSimplexNoise noise;

void setup()
{
  // Fixes some issues with rendering points close to each other.
  hint(ENABLE_STROKE_PURE);
  noise = new OpenSimplexNoise(12345);
  size(800, 800, P2D);
  background(0);
  
  // Anything over 60 should work.
  frameRate(120);
  
  // Keeps smoothing to a minimum in an attempt to get sharp pixels 
  // at a strokeWeight of 1.
  ((PGraphicsOpenGL)getGraphics()).textureSampling(1);
  noSmooth();
  
  // Makes point()s look like squares (good for pixel aesthetic).
  strokeCap(PROJECT);
   
  // If you are using beginShape()/endShape(), turn this off.
  noFill();
  
  // Let's us do smoother color blending. 
  colorMode(HSB, 360, 100, 100, 100);
  blendMode(BLEND);
  
  background(0);
  stroke(255, 255);
}

// Used for detecting if recording is finished. Don't mess with initialization.
float counter = 0;

// Used for keypress detection so you don't give repeated inputs on one press.
boolean s = false;
boolean ps = false;

// Use this as a time offset for trig and noise functions.
float off = 0;

// TURN THIS OFF UNLESS NECESSARY:
// Causes a lot of lag and fills up your drive.
boolean recording = false;

// This is multiplied by 2 since I render in 120fps.
// frameRate caps at your monitor's refresh rate so be careful.
// Feel free to remove.
float seconds = 5 * 2;
float cycles = 1;

// Two alternate ways to determine frame count:
// 1) Classic: just # of seconds
// 2) Periodic: Allows you to get a perfect loop if you use
//    off in calculations without any weird operations.
//int frame_count = (int)(seconds * frameRate);
int frame_count = (int)(TWO_PI * 100 * cycles);

// Stores the previous point/vertex coordinate
float px = 0;
float py = 0;

// Processing doesn't have this built in for some reason.
int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

void draw()
{
  float fade = 0.05;
  // Instead of using background, I use a screen-filling rect
  // so I can use alpha to keep some of the previous output around.
  // fade = 1.0 (just override previous output)
  // fade = 0.0 (no change to previous output)
  fill(0, 0, 0, fade * 100);
  rect(-50, -50, width + 50, width + 50);
  
  // My setup allows you to render multiple versions of the same
  // sketch simultaneously in separate cells of a grid.
  // You can technically use non-integer values but it looks a little strange.
  float dim = 1;
  float rows = dim;
  float cols = dim;
  
  float grid_size = width / dim;
  
  push();
  
  // You can use k and l as more input to noise and trig functions.
  // Just divide by rows and cols respectively if you want a [0,1] input 
  // for any functions.
  for (float k = 0; k < rows; k++)
  {
    for (float l = 0; l < cols; l++)
    {
      // In case you just want a 1D index as an input.
      float index = k * dim + l;
      
      // The origin of each iteration is at the exact center of each cell.
      // You can draw things in a range of (-grid_size/2, -grid_size/2) to
      // (grid_size/2, grid_size/2) before starting to bleed into other cells.
      // This can have a pretty cool effect so don't be afraid to try it out.
      push();
      translate((k + 0.5) * grid_size, (l + 0.5) * grid_size);
      
      // Within each cell I also have another loop that draws variations of
      // the same operations. Use j/num for a [0,1] input or just use j as is.
      int num = 1;
      
      // This is the pixel size of each point.
      // It also snaps the point by this value.
      float fat = 2.0f;
      for (float j = 1; j <= num; j += 1)
      {
        // In case you want to do any per iteration transforms.
        push();
        //beginShape();
        
        // Stores trig function outputs of the previous "circle" iteration.
        float pxOff = 0;
        float pyOff = 0;
        
        // Draws a circle using parametric form instead of circle().
        // Allows a lot of flexibility with per-point radius.
        for (float i = 0; i <= TAU; i += 0.01)
        { 
        
          // You can manipulate this value to rotate your point around the origin
          // without breaking from the pixel grid by using rotate().
          float s = 0;
          
          float xOff = cos(i);
          float yOff = sin(i);
          
          float r = grid_size / 6;
          
          strokeWeight(fat);
          float x0 = xOff * r ;
          float y0 = yOff * r ;
          float x = x0*cos(s) - y0*sin(s);
          float y = x0*sin(s) + y0*cos(s);
          
          x = round(x / fat) * fat;
          y = round(y / fat) * fat;

          point(x, y);
          
          px = x;
          py = y;
          pxOff = xOff;
          pyOff = yOff;
        }
        //endShape(CLOSE);
        pop();
      }
      pop();  
    }
  }
  
  pop();

  counter++;  
  off += 0.01;

  // NOTE: If you are trying to make a new recording, make
  // sure that your "frames" folder is empty in your working directory.
  // You can use the Movie Maker in the Tools tab or some other tool 
  // to stitch together a video after.
  if (counter <= frame_count && recording)
  {
    saveFrame("frames/fr####.tif");
    println("saving frame: " + counter + "/" + frame_count);
  }
  if (counter > frame_count && recording)
  {
    exit();
  }
  
  // Pressing any key while your sketch is running outputs a 
  // current snapshot of the sketch to a folder in its working directory.
  // It is labeled by a lot of redundant timestamp info so nothing gets 
  // overridden.
  ps = s;
  s = keyPressed;
  if (s && !ps)
  {
    saveFrame("screenshots/yeah" + year() + "-" + month() + "-" + day() + "-" + second() + "-" + millis() + "-" + ".png");
    println("saved a screenshot!");
    
  }
}
