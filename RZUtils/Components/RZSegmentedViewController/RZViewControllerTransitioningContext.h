//
//  RZViewControllerTransitioningContext.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/5/13.
//

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


/** 
 *  A class that is used to use custom transitions with in ChildViewControllers.
 *  Given the From - To - and Container view this class will return what is required
 *  to implement a custom ViewController Transition.
 *
 *  This class will need further testing with a few different animations.
 */

#import <Foundation/Foundation.h>

@class RZViewControllerTransitioningContext;

@interface RZViewControllerTransitioningContext : NSObject <UIViewControllerContextTransitioning>

// Completion block for after the transition happens
@property (nonatomic, copy) void (^completionBlock)(BOOL succeeded, RZViewControllerTransitioningContext* transitioningContext);

//Sets if the transition will be animated or not
@property (nonatomic, assign) BOOL animated;

// The parent ViewController.  Used to call didMoveToParentViewController: and other containment methods on the ChildViewControllers.
@property (nonatomic, weak) UIViewController* parentViewController;

// All parameters are required and non can be nil.
- (instancetype)initWithFromViewController:(UIViewController *)fromVC
                          toViewController:(UIViewController *)toVC
                             containerView:(UIView *)containerView;


@end
