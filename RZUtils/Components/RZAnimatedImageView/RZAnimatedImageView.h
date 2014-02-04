//
//  RZAnimatedImageView.h
//  Raizlabs
//
//  Created by Nick Donaldson on 1/6/14.
//  Copyright (c) 2014 Raizlabs. 
//

//  A custom png-sequence animated image view with completion block support

#import <UIKit/UIKit.h>

typedef void (^RZAnimatedImageViewCompletion)(BOOL finished);

@interface RZAnimatedImageView : UIView

@property (nonatomic, copy) NSArray *animationImages;
@property (nonatomic) NSTimeInterval animationDuration;

- (void)startAnimatingWithRepeatCount:(NSUInteger)repeatCount completion:(RZAnimatedImageViewCompletion)completion;
- (void)stopAnimating;

@end
