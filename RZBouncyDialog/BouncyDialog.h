//
//  BouncyDialog.h
//  RZUtils
//
//  Created by Robert Sesek on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// This UIView is meant to act as a modal dialog that, when shown, performs a
// cool bouncing animation. The dialog holds one subview, a |contentView|, which
// gets a black, transparent border.

@interface BouncyDialog : UIView
{
	UIView* contentView;
	
	BOOL showTitleBar;
	NSString* titleBarText;
}

@property (retain) UIView* contentView;
@property BOOL showTitleBar;
@property (copy) NSString* titleBarText;

- (id)initWithContentView:(UIView*)aContentView;

- (void)show;
- (void)hide;

@end
