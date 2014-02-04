//
//  UIAlertView+CompletionBlocks.h
//
//  Created by Nick Donaldson on 4/10/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <UIKit/UIKit.h>

typedef void (^RZAlertViewCompletionBlock)(NSInteger dismissalButtonIndex);

@interface UIAlertView (RZCompletionBlocks)

- (void)showWithCompletionBlock:(RZAlertViewCompletionBlock)completion;

@end
