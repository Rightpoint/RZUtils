//
//  RZSingleChildContainerViewController.m
//
//  Created by Nick Donaldson on 10/3/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import "RZSingleChildContainerViewController.h"

@interface RZSingleChildContainerTransitionContext : NSObject <UIViewControllerContextTransitioning>

- (id)initWithContainerVC:(RZSingleChildContainerViewController *)containerVC fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC;

@end

@interface RZSingleChildContainerAlphaTransitioner : NSObject <UIViewControllerAnimatedTransitioning>

@end

// -------

@interface RZSingleChildContainerViewController ()

@property (nonatomic, strong) NSMutableArray *viewLoadedBlocks;

@end

@implementation RZSingleChildContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewLoadedBlocks = [NSMutableArray array];
        _contentVCAnimatedTransition = [RZSingleChildContainerAlphaTransitioner new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (void(^block)() in self.viewLoadedBlocks)
    {
        block();
    }
    [self.viewLoadedBlocks removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.currentContentViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.currentContentViewController endAppearanceTransition];
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

- (UIViewController*)childViewControllerForStatusBarStyle
{
    return self.currentContentViewController;
}

- (UIViewController *)currentContentViewController
{
    UIViewController *currentChild = nil;
    if (self.childViewControllers.count > 0)
    {
        currentChild = [self.childViewControllers objectAtIndex:0];
    }
    return currentChild;
}

- (void)setContentVCAnimatedTransition:(id<UIViewControllerAnimatedTransitioning>)contentVCAnimatedTransition
{
    _contentVCAnimatedTransition = contentVCAnimatedTransition ? contentVCAnimatedTransition : [RZSingleChildContainerAlphaTransitioner new];
}

- (void)performBlockWhenViewLoaded:(void (^)())block
{
    NSParameterAssert(block);
    if (self.isViewLoaded)
    {
        block();
    }
    else
    {
        [self.viewLoadedBlocks addObject:[block copy]];
    }
}

- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    __weak __typeof(self) wself = self;
    
    [self performBlockWhenViewLoaded:^{
        
        UIViewController *currentChild = wself.currentContentViewController;
        
        // this can happen when the view hasn't been presented yet - don't prematurely pass appearance transition methods
        BOOL hasWindow = [self.view window] != nil;
        
        if (animated)
        {
            if (hasWindow)
            {
                [currentChild beginAppearanceTransition:NO animated:YES];
            }
            [currentChild willMoveToParentViewController:nil];
            [wself addChildViewController:viewController];
            viewController.view.frame = [wself childContentContainerView].bounds;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (hasWindow)
            {
                [viewController beginAppearanceTransition:YES animated:YES];
            }
            RZSingleChildContainerTransitionContext *ctx = [[RZSingleChildContainerTransitionContext alloc] initWithContainerVC:wself
                                                                                                                         fromVC:currentChild
                                                                                                                           toVC:viewController];
            [wself.contentVCAnimatedTransition animateTransition:ctx];
        }
        else
        {
            if (hasWindow)
            {
                [currentChild beginAppearanceTransition:NO animated:NO];
            }
            [currentChild.view removeFromSuperview];
            [currentChild removeFromParentViewController];
            if (hasWindow)
            {
                [currentChild endAppearanceTransition];
            }
            
            [wself addChildViewController:viewController];
            viewController.view.frame = [wself childContentContainerView].bounds;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (hasWindow)
            {
                [viewController beginAppearanceTransition:YES animated:NO];
            }
            [[wself childContentContainerView] addSubview:viewController.view];
            [viewController didMoveToParentViewController:wself];
            if (hasWindow)
            {
                [viewController endAppearanceTransition];
            }
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }];
}


- (UIView *)childContentContainerView
{
    return self.view;
}

@end

@implementation RZSingleChildContainerTransitionContext
{
    __weak RZSingleChildContainerViewController *_containerVC;
    __strong UIViewController *_fromVC;
    __strong UIViewController *_toVC;
}

- (id)initWithContainerVC:(RZSingleChildContainerViewController *)containerVC fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC
{
    self = [super init];
    if (self)
    {
        _containerVC = containerVC;
        _fromVC = fromVC;
        _toVC = toVC;
    }
    return self;
}

- (UIView *)containerView
{
    return [_containerVC childContentContainerView];
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
    [_fromVC.view removeFromSuperview]; // just in case it didn't happen in the animation
    [_fromVC removeFromParentViewController];
    [_toVC didMoveToParentViewController:_containerVC];
    if ([_containerVC.view window] != nil)
    {
        [_fromVC endAppearanceTransition];
        [_toVC endAppearanceTransition];
    }
    [_containerVC setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    if ([key isEqualToString:UITransitionContextFromViewControllerKey])
    {
        return _fromVC;
    }
    else if ([key isEqualToString:UITransitionContextToViewControllerKey])
    {
        return _toVC;
    }
    
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    if ([_fromVC isEqual:vc])
    {
        return [[_containerVC childContentContainerView] frame];
    }
    
    // to VC starts off screen
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    if ([_toVC isEqual:vc])
    {
        return [[_containerVC childContentContainerView] frame];
    }
    
    // from VC starts off screen
    return CGRectZero;
}

@end


@implementation RZSingleChildContainerAlphaTransitioner

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    toViewController.view.alpha = 0.f;
    [container addSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
        [fromViewController.view setAlpha:0.f];
        [toViewController.view setAlpha:1.f];
    } completion:^(BOOL finished) {
        fromViewController.view.alpha = 1.f;
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

@end
