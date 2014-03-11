//
//  RZRevealViewController.h
//  Raizlabs
//
//  Created by Joe Goullaud on 2/17/12.
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
