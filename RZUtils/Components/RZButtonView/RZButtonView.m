//
//  RZButtonView.m
//  Raizlabs
//
//  Created by Nick Donaldson on 11/19/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import "RZButtonView.h"

@interface RZButtonView ()

- (void)setSubviewsHighlighted:(BOOL)highlighted forView:(UIView *)view;

@end

@implementation RZButtonView

- (void)setSubviewsHighlighted:(BOOL)highlighted forView:(UIView *)view
{
    [[view subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        
        if ([subview respondsToSelector:@selector(setHighlighted:)])
        {
            NSMethodSignature *ms = [subview methodSignatureForSelector:@selector(setHighlighted:)];
            NSInvocation *iv = [NSInvocation invocationWithMethodSignature:ms];
            [iv setTarget:subview];
            [iv setSelector:@selector(setHighlighted:)];
            
            BOOL hlt = highlighted;
            [iv setArgument:&hlt atIndex:2];
            
            [iv invoke];
        }
        
        // recursion!!
        [self setSubviewsHighlighted:highlighted forView:subview];
    }];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setSubviewsHighlighted:YES forView:self];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setSubviewsHighlighted:NO forView:self];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self setSubviewsHighlighted:NO forView:self];
}

@end
