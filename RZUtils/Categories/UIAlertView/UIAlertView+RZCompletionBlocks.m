//
//  UIAlertView+RZCompletionBlocks.m
//  Raizlabs
//
//  Created by Nick Donaldson on 4/10/13.

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

#import "UIAlertView+RZCompletionBlocks.h"
#import <objc/runtime.h>

@interface AlertViewCompletionDelegate : NSObject <UIAlertViewDelegate>

@property (copy, nonatomic) RZAlertViewCompletionBlock completionBlock;

- (id)initWithCompletionBlock:(RZAlertViewCompletionBlock)completion;

@end

@implementation AlertViewCompletionDelegate

- (id)initWithCompletionBlock:(RZAlertViewCompletionBlock)completion
{
    self = [super init];
    if (self){
        self.completionBlock = completion;
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock){
        self.completionBlock(buttonIndex);
        self.completionBlock = nil; // prevent retain cycle if completion block captures alertView
    }
}

@end

@implementation UIAlertView (RZCompletionBlocks)

- (void)rz_showWithCompletionBlock:(RZAlertViewCompletionBlock)completion
{
    if (completion){
        AlertViewCompletionDelegate *alertDelegate = [[AlertViewCompletionDelegate alloc] initWithCompletionBlock:completion];
        self.delegate = alertDelegate;
        
        // Set associated object to retain it. Will be released when alertview deallocs, since delegate is weak reference.
        objc_setAssociatedObject(self, "AlertViewCompletionDelegate", alertDelegate, OBJC_ASSOCIATION_RETAIN);
    }
    
    [self show];
}

@end
