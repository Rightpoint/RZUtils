//
//  RZRevealViewController.h
//  Raizlabs
//
//  Created by Joe Goullaud on 2/17/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    RZRevealViewControllerPositionLeft,
    RZRevealViewControllerPositionRight,
    RZRevealViewControllerPositionNone,
    RZRevealViewControllerPositionBoth
}
RZRevealViewControllerPosition;

typedef void (^RZRevealViewControllerCompletionBlock)(BOOL succeeded);


@protocol RZRevealViewControllerDelegate;

@interface RZRevealViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIViewController *mainViewController;
@property (strong, nonatomic) IBOutlet UIViewController *leftHiddenViewController;
@property (strong, nonatomic) IBOutlet UIViewController *rightHiddenViewController;
// Defaults to having a basic shadow, change this view's CALayer shadow properties to adjust.
@property (strong, nonatomic) UIView *mainVCWrapperView;

// Pan gesture for opening/closing reveal panel. Its delegate may not be changed or an exception will be thrown.
@property (strong, readonly, nonatomic) UIPanGestureRecognizer *revealPanGestureRecognizer;

@property (assign, nonatomic, readonly, getter = isLeftHiddenViewControllerRevealed) BOOL leftHiddenViewControllerRevealed;
@property (assign, nonatomic, readonly, getter = isRightHiddenViewControllerRevealed) BOOL rightHiddenViewControllerRevealed;

@property (assign, nonatomic, getter = isRevealEnabled) BOOL revealEnabled; // Defaults to YES
@property (assign, nonatomic, getter = isPeekEnabled) BOOL peekEnabled; // Defaults to NO

// Allow interaction with main VC while hidden VC is revealed. Defaults to NO.
@property (assign, nonatomic) BOOL allowMainVCInteractionWhileRevealed;

@property (assign, nonatomic) CGFloat revealOffset;                             // Defaults to zero. Pan distance must exceed this to trigger reveal/hide.
@property (assign, nonatomic) CGFloat quickPeekHiddenOffset;                    // Defaults to self.view.bounds.size.width / 4.0
@property (assign, nonatomic) CGFloat peekHiddenOffset;                         // Defaults to self.view.bounds.size.width / 2.0
@property (assign, nonatomic) CGFloat showHiddenOffset;                         // Defaults to self.view.bounds.size.width * 0.85
@property (assign, nonatomic) CGFloat revealGestureThreshold;                   // Defaults to CGFLOAT_MAX
@property (assign, nonatomic) CGFloat maxDragDistance;                          // Defaults to self.view.bounds.size.width
@property (assign, nonatomic) CGFloat openRevealGestureThreashold;

@property (weak, nonatomic) id<RZRevealViewControllerDelegate> delegate;

- (id)initWithMainViewController:(UIViewController*)mainVC
        leftHiddenViewController:(UIViewController*)leftVC
        rightHiddenViewController:(UIViewController*)rightVC;

- (id)initWithMainViewController:(UIViewController*)mainVC
        leftHiddenViewController:(UIViewController*)leftVC
       rightHiddenViewController:(UIViewController*)rightVC
                 usesEdgeGesture:(BOOL)usesEdgeGesture;

- (IBAction)showLeftHiddenViewControllerAnimated:(BOOL)animated;
- (void)showLeftHiddenViewControllerAnimated:(BOOL)animated completionBlock:(RZRevealViewControllerCompletionBlock)block;
- (void)showLeftHiddenViewControllerWithOffset:(CGFloat)offset animated:(BOOL)animated;
- (IBAction)peekLeftHiddenViewControllerAnimated:(BOOL)animated;
- (void)peekLeftHiddenViewControllerWithOffset:(CGFloat)offset animated:(BOOL)animated;
- (IBAction)hideLeftHiddenViewControllerAnimated:(BOOL)animated;
- (void)hideLeftHiddenViewControllerAnimated:(BOOL)animated completionBlock:(RZRevealViewControllerCompletionBlock)block;

- (IBAction)showRightHiddenViewControllerAnimated:(BOOL)animated;
- (void)showRightHiddenViewControllerAnimated:(BOOL)animated completionBlock:(RZRevealViewControllerCompletionBlock)block;
- (void)showRightHiddenViewControllerWithOffset:(CGFloat)offset animated:(BOOL)animated;
- (IBAction)peekRightHiddenViewControllerAnimated:(BOOL)animated;
- (void)peekRightHiddenViewControllerWithOffset:(CGFloat)offset animated:(BOOL)animated;
- (IBAction)hideRightHiddenViewControllerAnimated:(BOOL)animated;
- (void)hideRightHiddenViewControllerAnimated:(BOOL)animated completionBlock:(RZRevealViewControllerCompletionBlock)block;

- (void)bounceLeftHiddenViewController;
- (void)bounceRightHiddenViewController;

@end

@protocol RZRevealViewControllerDelegate <NSObject>

@optional

// Implement and return NO to disable a potential reveal gesture/action conditionally
- (BOOL)revealControllerShouldBeginReveal:(RZRevealViewController*)revealController;

- (void)revealController:(RZRevealViewController*)revealController willShowHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;
- (void)revealController:(RZRevealViewController*)revealController didShowHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;
- (void)revealController:(RZRevealViewController*)revealController willHideHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;
- (void)revealController:(RZRevealViewController*)revealController didHideHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;
- (void)revealController:(RZRevealViewController*)revealController willPeekHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;
- (void)revealController:(RZRevealViewController*)revealController didPeekHiddenController:(UIViewController*)hiddenController position:(RZRevealViewControllerPosition)position;

@end


@interface UIViewController (RZRevealViewController) <RZRevealViewControllerDelegate>

@property (weak, nonatomic, readonly) RZRevealViewController *revealViewController;

@end
