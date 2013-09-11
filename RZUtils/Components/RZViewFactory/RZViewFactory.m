//
//  RZViewFactory.m
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZViewFactory.h"

@implementation RZViewFactory

@synthesize view = _view;

+ (UIView *)viewWithNibNamed:(NSString *)nibName
{
    RZViewFactory *viewFactory = [[RZViewFactory alloc] init];
    [[NSBundle mainBundle] loadNibNamed:nibName owner:viewFactory options:nil];
    return viewFactory.view;
}

@end

@implementation UIView (RZViewFactory)

+ (UIView *)view
{
    // Guess nib name.
    Class cellClass = [self class];
    NSString *classString = NSStringFromClass(cellClass);
    return [RZViewFactory viewWithNibNamed:classString];
}

@end