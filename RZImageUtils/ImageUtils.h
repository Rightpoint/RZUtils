//
//  ImageUtils.h
//  GPSTwit
//
//  Created by Craig on 8/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// This class is used to perform various operations on UIImage objects
@interface ImageUtils : NSObject {

}

// this will scale an image based on a maximum dimension. The resulting
// image will maintain is aspect ratio, but if either dimension of the 
// orignal image is larger than max, the image will be scaled so the 
// new image's largest dimension is max. Smaller images will not be scaled
// up. Image will be rotated based on its orientation
+(UIImage *)scaleAndRotateImage:(UIImage *)image toMax:(int)max;

// This will scale an image to the exact dimensions given, regardless of loss of 
// aspect ratio. If the rotate flag is set, the orientation is read from the image
// exif data, and the image data is rotated accordingly
+(UIImage*)transformImage:(UIImage*)image Width:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate;

@end
