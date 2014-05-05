```java
import flash.display.*;
import flash.geom.*;
var clip:MovieClip;
var clip2:MovieClip = createEmptyMovieClip("clip2", 0);
clip2._x = clip._x+100;
clip2._y = clip._y;
var bmp:BitmapData = new BitmapData(clip._width, clip._height);
clip2.attachBitmap(bmp,1);
bmp.draw(clip);
clip2._width = clip._width;
clip2._height = clip._height;
clip2._rotation = 90;
```