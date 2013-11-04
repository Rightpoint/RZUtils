//
//  UIAlertView+CompletionBlocks.m
//  Raizlabs
//
//  Created by Nick Donaldson on 4/10/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
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

- (void)showWithCompletionBlock:(RZAlertViewCompletionBlock)completion
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