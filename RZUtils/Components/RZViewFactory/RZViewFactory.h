//
//  RZViewFactory.h
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <Foundation/Foundation.h>

@interface UIView (RZViewFactory)

// This method of loading views from nibs only works if nib's owner is nil
//
//  EXAMPLE: MyView *myView = [MyView rz_loadFromNibNamed:nil];
//  The above will try to find a xib called "MyView.xib" with a top-level
//  object of custom class "MyView", and will return an instance loaded from that xib
+ (instancetype)rz_loadFromNibNamed:(NSString*)nibNameOrNil;

@end
