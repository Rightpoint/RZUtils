//
//  ImageUtils.m
//  GPSTwit
//
//  Created by Craig on 8/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ImageUtils.h"


@implementation ImageUtils

+(UIImage *)scaleAndRotateImage:(UIImage *)image toMax:(int)max 
{
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	
	CGFloat scaledWidth;
	CGFloat scaledHeight;
	
	if (width > max || height > max) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			scaledWidth = max;
			scaledHeight = scaledWidth / ratio;
		}
		else {
			scaledHeight = max;
			scaledWidth = scaledHeight * ratio;
		}
	}
	else
	{
		scaledWidth = width;
		scaledHeight = height;
	}
	
	return [ImageUtils transformImage:image Width:scaledWidth height:scaledHeight rotate:YES];
		
}

+(UIImage*)transformImage:(UIImage*)image Width:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate {
	int destW = (int)round(width);
	int destH = (int)round(height);
	int sourceW = (int)round(width);
	int sourceH = (int)round(height);
	if (rotate) {
		if (image.imageOrientation == UIImageOrientationRight
			|| image.imageOrientation == UIImageOrientationLeft) {
			sourceW = (int)round(height);
			sourceH = (int)round(width);
		}
	}

	CGImageRef imageRef = image.CGImage;	
	CGContextRef bitmap = CGBitmapContextCreate(NULL,
												destW,
												destH,
												CGImageGetBitsPerComponent(imageRef), 
												4*destW, 
												CGImageGetColorSpace(imageRef),
												kCGImageAlphaPremultipliedFirst);
	
	if (rotate) {
		if (image.imageOrientation == UIImageOrientationDown) {
			CGContextTranslateCTM(bitmap, sourceW, sourceH);
			CGContextRotateCTM(bitmap, 180 * (M_PI/180));
		} else if (image.imageOrientation == UIImageOrientationLeft) {
			CGContextTranslateCTM(bitmap, sourceH, 0);
			CGContextRotateCTM(bitmap, 90 * (M_PI/180));
		} else if (image.imageOrientation == UIImageOrientationRight) {
			CGContextTranslateCTM(bitmap, 0, sourceW);
			CGContextRotateCTM(bitmap, -90 * (M_PI/180));
		}
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* result = [UIImage imageWithCGImage:ref];
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;
}

@end
