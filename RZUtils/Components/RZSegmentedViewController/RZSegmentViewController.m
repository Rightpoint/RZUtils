//
//  RZSegmentViewController.m
//
//  Created by Joe Goullaud on 11/5/12.
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

#import "RZSegmentViewController.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#import "RZViewControllerTransitioningContext.h"
#endif

#define kDefaultSegmentControlHeight 44.0

@interface RZSegmentViewController ()

@property (nonatomic, weak) UIViewController *currentViewController;
@property (nonatomic, assign) BOOL viewIsAppearing;

- (void)setupSegmentViewController;

- (void)updateSegmentControl:(UISegmentedControl*)segmentControl forViewControllers:(NSArray*)viewControllers;

- (void)showSegmentViewControllerAtIndex:(NSUInteger)index;

@end

@implementation RZSegmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupSegmentViewController];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupSegmentViewController];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)setupSegmentViewController
{
    // override in sub-class as needed
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.contentView == nil)
    {
        UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        contentView.autoresizesSubviews = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if( self.shouldSegmentedControlOverlapContentView == NO ) {
            // inset content-view frame if desired
            contentView.frame = CGRectMake(contentView.frame.origin.x,
                                           contentView.frame.origin.y + kDefaultSegmentControlHeight,
                                           contentView.frame.size.width,
                                           contentView.frame.size.height - kDefaultSegmentControlHeight);
        }
        [self.view addSubview:contentView];
        [self.view sendSubviewToBack:contentView];
        
        self.contentView = contentView;
    }
    
    if (self.segmentControl == nil)
    {
        UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDefaultSegmentControlHeight)];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
#endif
        segmentControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:segmentControl];
        
        self.segmentControl = segmentControl;
    }
    
    [self updateSegmentControl:self.segmentControl forViewControllers:self.viewControllers];
    [self.segmentControl setSelectedSegmentIndex:self.selectedIndex];
    [self showSegmentViewControllerAtIndex:self.selectedIndex];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewIsAppearing = YES;
    [self.currentViewController beginAppearanceTransition:YES animated:animated];
    self.segmentControl.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewIsAppearing = NO;
    [self.currentViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.currentViewController endAppearanceTransition];
}

#pragma mark - Properties

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:YES];
    
    // TODO: Error handling if index is out of bounds?
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (selectedIndex < self.segmentControl.numberOfSegments)
    {
        [self.segmentControl setSelectedSegmentIndex:selectedIndex];
        [self showSegmentViewControllerAtIndex:selectedIndex animated:animated];
        _selectedIndex = selectedIndex;
    }
}

#pragma mark - Private

- (void)updateSegmentControl:(UISegmentedControl*)segmentControl forViewControllers:(NSArray*)viewControllers
{
    [segmentControl removeAllSegments];
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController*)obj;
        [segmentControl insertSegmentWithTitle:vc.title atIndex:idx animated:NO];
    }];
}

- (void)showSegmentViewControllerAtIndex:(NSUInteger)index
{
    [self showSegmentViewControllerAtIndex:index animated:NO];
}

- (void)showSegmentViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    BOOL viewVisible = self.isViewLoaded ? (self.view.window != nil) : NO;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    if (self.animationTransitioning && animated && viewVisible)
    {
        UIViewController *oldVC = self.currentViewController;
        [oldVC willMoveToParentViewController:nil];
        [oldVC beginAppearanceTransition:NO animated:YES];
        
        UIViewController* nextVC = [self.viewControllers objectAtIndex:index];
        nextVC.view.frame = self.contentView.bounds;
        [self addChildViewController:nextVC];
        [nextVC beginAppearanceTransition:YES animated:YES];
        
        RZViewControllerTransitioningContext* transitioningContext = [[RZViewControllerTransitioningContext alloc] initWithFromViewController:oldVC
                                                                                                                             toViewController:nextVC
                                                                                                                                containerView:self.contentView];
        transitioningContext.parentViewController = self;
        
        __weak __typeof(self)wself = self;
        transitioningContext.completionBlock = ^(BOOL succeeded, RZViewControllerTransitioningContext* transitioningContext) {
            [oldVC endAppearanceTransition];
            [nextVC endAppearanceTransition];
            wself.segmentControl.userInteractionEnabled = YES;
        };
        self.segmentControl.userInteractionEnabled = NO;
        [self.animationTransitioning animateTransition:transitioningContext];
        self.currentViewController = nextVC;
    }
    else
    {
#endif
        // Transition out the old view controller
        if (self.currentViewController != nil)
        {
            if (viewVisible)
            {
                [self.currentViewController beginAppearanceTransition:NO animated:NO];
            }
            [self.currentViewController willMoveToParentViewController:nil];
            [self.currentViewController.view removeFromSuperview];
            [self.currentViewController removeFromParentViewController];
            if (viewVisible)
            {
                [self.currentViewController endAppearanceTransition];
            }
        }
        
        // Tranisition in the new view controller.
        self.currentViewController = [self.viewControllers objectAtIndex:index];
        
        [self addChildViewController:self.currentViewController];
        self.currentViewController.view.frame = self.contentView.bounds;
        self.currentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Always begin the appearance transition if the view is visible, even if it's in the process of appearing
        if (viewVisible || self.viewIsAppearing)
        {
            [self.currentViewController beginAppearanceTransition:YES animated:NO];
        }
        
        [self.contentView addSubview:self.currentViewController.view];
        
        // If the segment VC has not yet appeared, DO NOT end the appearance transition
        if (viewVisible)
        {
            [self.currentViewController endAppearanceTransition];
        }
                
        [self.currentViewController didMoveToParentViewController:self];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectSegmentAtIndex:)])
        {
            [self.delegate didSelectSegmentAtIndex:index];
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    }
#endif
}
- (IBAction)segmentControlValueChanged:(id)sender
{
    NSInteger selectedIndex = self.segmentControl.selectedSegmentIndex;

    if (self.delegate && [self.delegate respondsToSelector:@selector(willSelectSegmentAtIndex:currentIndex:)])
    {
        [self.delegate willSelectSegmentAtIndex:selectedIndex currentIndex:self.selectedIndex];
    }

    [self showSegmentViewControllerAtIndex:selectedIndex animated:YES];
    _selectedIndex = selectedIndex;
    
}

@end
