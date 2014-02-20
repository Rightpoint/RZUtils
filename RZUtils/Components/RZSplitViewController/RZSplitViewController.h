//
//  RZSplitViewController.h
//  RZSplitViewController-Demo
//
//  Created by Joe Goullaud on 8/6/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RZSplitViewControllerDelegate;

@interface RZSplitViewController : UIViewController

@property (copy, nonatomic) NSArray *viewControllers;
@property (weak, nonatomic) id <RZSplitViewControllerDelegate> delegate;        // Not used yet
@property (strong, nonatomic) UIImage *collapseBarButtonImage;
@property (strong, nonatomic) UIImage *expandBarButtonImage;
@property (strong, nonatomic, readonly) UIBarButtonItem *collapseBarButton;
@property (assign, nonatomic, getter = isCollapsed) BOOL collapsed;
@property (nonatomic, assign) CGFloat masterWidth;
@property (strong, nonatomic) UIColor* viewBorderColor;
@property (nonatomic, assign) CGFloat viewCornerRadius;
@property (nonatomic, assign) CGFloat viewBorderWidth;


@property (nonatomic, readonly) UIViewController *masterViewController;
@property (nonatomic, readonly) UIViewController *detailViewController;

- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated;
- (void)setDetailViewController:(UIViewController*)detailVC;
- (void)setMasterViewController:(UIViewController*)masterVC;

@end


// Delegate is not implemented yet
@protocol RZSplitViewControllerDelegate <NSObject>

- (BOOL)splitViewController:(RZSplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;

- (void)splitViewController:(RZSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;

- (void)splitViewController:(RZSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)splitViewController:(RZSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController;

@end


@interface UIViewController (RZSplitViewController)

@property (strong, nonatomic, readonly) RZSplitViewController *rzSplitViewController;

@end