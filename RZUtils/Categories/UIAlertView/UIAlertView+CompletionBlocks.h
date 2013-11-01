//
//  UIAlertView+CompletionBlocks.h
//  Raizlabs
//
//  Created by Nick Donaldson on 4/10/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AlertViewCompletionBlock)(NSInteger dismissalButtonIndex);

@interface UIAlertView (CompletionBlocks)

- (void)showWithCompletionBlock:(AlertViewCompletionBlock)completion;

@end
