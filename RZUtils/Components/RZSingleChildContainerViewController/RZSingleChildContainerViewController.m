//
//  RZSingleChildContainerViewController.m
//
//  Created by Nick Donaldson on 10/3/13.

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

#import "RZSingleChildContainerViewController.h"

@interface RZSingleChildContainerTransitionContext : NSObject <UIViewControllerContextTransitioning>

@property (weak, nonatomic, readonly) RZSingleChildContainerViewController *containerVC;
@property (strong, nonatomic, readonly) UIViewController *fromVC;
@property (strong, nonatomic, readonly) UIViewController *toVC;
@property (copy, nonatomic, readonly) RZSingleChildContainerViewControllerCompletionBlock completionBlock;

- (id)initWithContainerVC:(RZSingleChildContainerViewController *)containerVC fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC completion:(RZSingleChildContainerViewControllerCompletionBlock)completion;

@end

static NSTimeInterval kRZSingleChildContainerAlphaTransitionerAnimationDuration = 0.25;

@interface RZSingleChildContainerAlphaTransitioner : NSObject <UIViewControllerAnimatedTransitioning>

@end


// -------

@interface RZSingleChildContainerViewController ()

@property (nonatomic, readwrite) BOOL isTransitioning; // internal readwrite redefinition

@property (nonatomic, strong) NSMutableArray *viewLoadedBlocks;

@property (weak, nonatomic) UIViewController *viewControllerOnWhichWeCalledBegin;

@property (copy, nonatomic) void(^queuedPresentationBlock)();

@end

@implementation RZSingleChildContainerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        _viewLoadedBlocks = [NSMutableArray array];
        _contentVCAnimatedTransition = [[RZSingleChildContainerAlphaTransitioner alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for ( void(^block)() in self.viewLoadedBlocks ) {
        block();
    }
    [self.viewLoadedBlocks removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // We want to make sure we don’t call endAppearanceTransition
    // on an object where we never called beginAppearanceTransition:animated:,
    // so keep track of which view controller we called this method on.
    // Note: self.currentContentViewController may be nil here.
    self.viewControllerOnWhichWeCalledBegin = self.currentContentViewController;

    [self.currentContentViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( self.viewControllerOnWhichWeCalledBegin == self.currentContentViewController ) {
        [self.currentContentViewController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentContentViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.currentContentViewController endAppearanceTransition];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.currentContentViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.currentContentViewController;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.currentContentViewController.supportedInterfaceOrientations;
}

- (UIViewController *)currentContentViewController
{
    UIViewController *currentChild = nil;
    if ( self.childViewControllers.count > 0 ) {
        currentChild = self.childViewControllers[0];
    }
    return currentChild;
}

- (void)setContentVCAnimatedTransition:(id <UIViewControllerAnimatedTransitioning>)contentVCAnimatedTransition
{
    _contentVCAnimatedTransition = contentVCAnimatedTransition ?: [[RZSingleChildContainerAlphaTransitioner alloc] init];
}

- (void)performBlockWhenViewLoaded:(void (^)())block
{
    NSParameterAssert(block);
    if ( self.isViewLoaded ) {
        block();
    }
    else {
        [self.viewLoadedBlocks addObject:[block copy]];
    }
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setContentViewController:viewController animated:animated completion:nil];
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(RZSingleChildContainerViewControllerCompletionBlock)completion
{
    __weak __typeof(self) weakSelf = self
    ;
    if ( self.isTransitioning ) {
      
        self.queuedPresentationBlock = ^{
            [weakSelf setContentViewController:viewController animated:animated completion:completion];
        };
        
        return;
    }
    
    // We need to set isTransitioning to NO once the transition completes.
    // Then we run the passed-in completion block if it is not nil.
    void (^compoundCompletion)(void) = ^{
        self.isTransitioning = NO;
        if ( completion ) {
            completion();
        }
        if ( self.queuedPresentationBlock != nil ) {
            self.queuedPresentationBlock();
            self.queuedPresentationBlock = nil;
        }
    };

    [self performBlockWhenViewLoaded:^{
        self.isTransitioning = YES;
        UIViewController *currentChild = weakSelf.currentContentViewController;

        if ( animated ) {

            [currentChild beginAppearanceTransition:NO animated:YES];

            [currentChild willMoveToParentViewController:nil];
            [weakSelf addChildViewController:viewController];
            viewController.view.frame = [weakSelf childContentContainerView].bounds;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

            [viewController beginAppearanceTransition:YES animated:YES];

            RZSingleChildContainerTransitionContext *ctx = [[RZSingleChildContainerTransitionContext alloc] initWithContainerVC:weakSelf
                                                                                                                         fromVC:currentChild
                                                                                                                           toVC:viewController
                                                                                                                     completion:compoundCompletion];
            [weakSelf.contentVCAnimatedTransition animateTransition:ctx];
        }
        else {
            
            // If a child is added before the container is in a window yet, viewWillAppear and viewDidAppear will be called twice.
            // The solution is not to send appearance transitions here but rather to let the container forward them from its own appearance cycle.
            BOOL hasWindow = [self.view window] != nil;
            
            [currentChild beginAppearanceTransition:NO animated:NO];
            [currentChild.view removeFromSuperview];
            [currentChild removeFromParentViewController];
            [currentChild endAppearanceTransition];

            [weakSelf addChildViewController:viewController];
            viewController.view.frame = [weakSelf childContentContainerView].bounds;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if ( hasWindow ) {
                [viewController beginAppearanceTransition:YES animated:NO];
            }
            [[weakSelf childContentContainerView] addSubview:viewController.view];
            [viewController didMoveToParentViewController:weakSelf];
            if ( hasWindow ) {
                [viewController endAppearanceTransition];
            }
            [self setNeedsStatusBarAppearanceUpdate];
            compoundCompletion();
        }
    }];
}


- (UIView *)childContentContainerView
{
    return self.view;
}

@end

@implementation RZSingleChildContainerTransitionContext

- (instancetype)initWithContainerVC:(RZSingleChildContainerViewController *)containerVC fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC completion:(RZSingleChildContainerViewControllerCompletionBlock)completion;
{
    self = [super init];
    if ( self ) {
        _containerVC = containerVC;
        _fromVC = fromVC;
        _toVC = toVC;
        _completionBlock = [completion copy];
    }
    return self;
}

- (UIView *)containerView
{
    return [self.containerVC childContentContainerView];
}

- (BOOL)isAnimated
{
    return YES;
}

- (BOOL)isInteractive
{
    return NO;
}

- (BOOL)transitionWasCancelled
{
    return NO;
}

- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationNone;
}

// These do nothing because it will never be interactive
- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

- (void)completeTransition:(BOOL)didComplete
{
    [self.fromVC.view removeFromSuperview]; // just in case it didn't happen in the animation
    [self.fromVC removeFromParentViewController];
    [self.toVC didMoveToParentViewController:self.containerVC];
    if ( [self.containerVC.view window] != nil ) {
        [self.fromVC endAppearanceTransition];
        [self.toVC endAppearanceTransition];
    }
    [self.containerVC setNeedsStatusBarAppearanceUpdate];

    if ( self.completionBlock ) {
        self.completionBlock();
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    UIViewController *viewController = nil;
    if ( [key isEqualToString:UITransitionContextFromViewControllerKey] ) {
        viewController = self.fromVC;
    }
    else if ( [key isEqualToString:UITransitionContextToViewControllerKey] ) {
        viewController = self.toVC;
    }
    
    return viewController;
}
- (UIView *)viewForKey:(NSString *)key
{
    UIView *view = nil;
    if ( [key isEqualToString:UITransitionContextFromViewKey] ) {
        view = self.fromVC.view;
    }
    else if ( [key isEqualToString:UITransitionContextToViewKey] ) {
        view = self.toVC.view;
    }

    return view;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    if ( [self.fromVC isEqual:vc] ) {
        return [[self.containerVC childContentContainerView] frame];
    }
    
    // the "to" VC starts off-screen
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    if ( [self.toVC isEqual:vc] ) {
        return [[self.containerVC childContentContainerView] frame];
    }
    
    // the "from" VC starts off-screen
    return CGRectZero;
}

- (CGAffineTransform)targetTransform
{
    return CGAffineTransformIdentity;
}

@end

@implementation RZSingleChildContainerAlphaTransitioner

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    toViewController.view.alpha = 0.0f;
    [container addSubview:toViewController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:0
                     animations:^{
                         [fromViewController.view setAlpha:0.0f];
                         [toViewController.view setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         fromViewController.view.alpha = 1.0f;
                         [transitionContext completeTransition:finished];
                     }];
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kRZSingleChildContainerAlphaTransitionerAnimationDuration;
}

@end