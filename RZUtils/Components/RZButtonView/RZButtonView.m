//
//  RZButtonView.m
//  Raizlabs
//
//  Created by Nick Donaldson on 11/19/13.
// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
