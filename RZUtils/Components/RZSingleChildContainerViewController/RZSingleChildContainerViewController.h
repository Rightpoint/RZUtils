//
//  RZSingleChildContainerViewController.h
//
//  Created by Nick Donaldson on 10/3/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <UIKit/UIKit.h>

@interface RZSingleChildContainerViewController : UIViewController

// The current content child (if any)
@property (nonatomic, readonly) UIViewController *currentContentViewController;

// Defaults to a simple alpha-fade transitioner. Set to another object to implement a custom transition
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> contentVCAnimatedTransition;

// Perform this block when the view is loaded. If already loaded, happens immediately.
// Useful for pre-configuring child viewcontrollers just after allocation, when view is not loaded yet.
- (void)performBlockWhenViewLoaded:(void(^)())block;

// Supports only a single child VC in its content area
// Subclasses should not override - override animation methods to customize animation transitions
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;

/* ---------- Override in Subclasses ------------
 *     Do not call these methods directly
 */

// Container view for the children. Defaults to self.view.
- (UIView *)childContentContainerView;

// --------------------------------------------

@end
