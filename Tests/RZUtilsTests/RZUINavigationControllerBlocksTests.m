//
//  UINavigationControllerBlocksTests.m
//  UINavigationControllerBlocksTests
//
//  Created by Andrew McKnight on 5/28/14.
//  Copyright (c) 2014 Andrew McKnight. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UINavigationController+RZBlocks.h"

static NSString* const kRZUINavigationControllerBlockTestVC1Title = @"First VC";
static NSString* const kRZUINavigationControllerBlockTestVC2Title = @"Second VC";
static NSString* const kRZUINavigationControllerBlockTestVC3Title = @"Third VC";
static NSString* const kRZUINavigationControllerBlockTestVC4Title = @"Fouth VC";

@interface RZUINavigationControllerBlocksTests : XCTestCase <UINavigationControllerDelegate>

@property (strong, nonatomic) UIViewController *vc1;
@property (strong, nonatomic) UIViewController *vc2;
@property (strong, nonatomic) UIViewController *vc3;
@property (strong, nonatomic) UIViewController *vc4;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSArray *allVCs;

@property (assign, nonatomic) BOOL preparationBlockCalled;
@property (assign, nonatomic) BOOL completionBlockCalled;

@end

@implementation RZUINavigationControllerBlocksTests

- (void)setUp
{
    [super setUp];
    
    self.vc1 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    self.vc1.title = kRZUINavigationControllerBlockTestVC1Title;
    self.vc2 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    self.vc2.title = kRZUINavigationControllerBlockTestVC2Title;
    self.vc3 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    self.vc3.title = kRZUINavigationControllerBlockTestVC3Title;
    self.vc4 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    self.vc4.title = kRZUINavigationControllerBlockTestVC4Title;
    self.allVCs = @[self.vc1, self.vc2, self.vc3, self.vc4];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.vc1];
    self.navController.delegate = self;
    
    self.preparationBlockCalled = NO;
    self.completionBlockCalled = YES;
}

- (void)testNavigationControllerPushPopWithBlocks
{
    [self pushPopAnimated:YES];
    
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self pushPopAnimated:NO];
}

- (void)pushPopAnimated:(BOOL)animated
{
    RZNavigationControllerCompletionBlock popToRootTestBlock = ^(UINavigationController *navigationController,
                                                                 UIViewController *presentedViewController,
                                                                 NSArray *poppedViewControllers) {
        
        [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2]];
        [navigationController rz_popToRootViewControllerAnimated:animated
                                                     preparation:^(UINavigationController *navigationController,
                                                                   UIViewController *presentingViewController) {
                                                         
                                                         [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2]];
                                                         self.preparationBlockCalled = YES;
                                                         
                                                     }
                                                      completion:^(UINavigationController *navigationController,
                                                                   UIViewController *presentedViewController,
                                                                   NSArray *poppedViewControllers) {
                                                          
                                                          [self checkIfNavigationController:navigationController hasVCs:@[self.vc1]];
                                                          
                                                      }];
        self.completionBlockCalled = YES;
        
    };
    
    RZNavigationControllerCompletionBlock popMultipleVCsTestBlock = ^(UINavigationController *navigationController,
                                                                      UIViewController *presentedViewController,
                                                                      NSArray *poppedViewControllers) {
        
        [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2, self.vc3]];
        [navigationController rz_setViewControllers:self.allVCs
                                           animated:animated
                                        preparation:^(UINavigationController *navigationController,
                                                      UIViewController *presentingViewController) {
                                            
                                            [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2, self.vc3]];
                                            self.preparationBlockCalled = YES;
                                            
                                        }
                                         completion:^(UINavigationController *navigationController,
                                                      UIViewController *presentedViewController,
                                                      NSArray *poppedViewControllers) {
                                             
                                             [navigationController rz_popToViewController:self.vc2
                                                                                 animated:animated
                                                                              preparation:^(UINavigationController *navigationController,
                                                                                            UIViewController *presentingViewController) {
                                                                                  
                                                                                  [self checkIfNavigationController:navigationController hasVCs:self.allVCs];
                                                                                  self.preparationBlockCalled = YES;
                                                                                  
                                                                              }
                                                                               completion:popToRootTestBlock];
                                             
                                         }];
        self.completionBlockCalled = YES;
        
    };
    
    RZNavigationControllerCompletionBlock popOneVCTestBlock = ^(UINavigationController *navigationController,
                                                                UIViewController *presentedViewController,
                                                                NSArray *poppedViewControllers) {
        
        [self checkIfNavigationController:navigationController hasVCs:self.allVCs];
        [navigationController rz_popViewControllerAnimated:animated
                                               preparation:^(UINavigationController *navigationController,
                                                             UIViewController *presentingViewController) {
                                                   
                                                   [self checkIfNavigationController:navigationController hasVCs:self.allVCs];
                                                   self.preparationBlockCalled = YES;
                                                   
                                               }
                                                completion:popMultipleVCsTestBlock];
        self.completionBlockCalled = YES;
        
    };
    
    RZNavigationControllerCompletionBlock pushRemainingVCsTestBlock = ^(UINavigationController *navigationController,
                                                                        UIViewController *presentedViewController,
                                                                        NSArray *poppedViewControllers) {
        
        [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2]];
        [navigationController rz_setViewControllers:self.allVCs
                                           animated:animated
                                        preparation:^(UINavigationController *navigationController,
                                                      UIViewController *presentingViewController) {
                                            
                                            [self checkIfNavigationController:navigationController hasVCs:@[self.vc1, self.vc2]];
                                            self.preparationBlockCalled = YES;
                                            
                                        }
                                         completion:popOneVCTestBlock];
        self.completionBlockCalled = YES;
        
    };
    
	[self.navController rz_pushViewController:self.vc2
	                                 animated:animated
	                              preparation: ^(UINavigationController *navigationController,
                                                 UIViewController *presentingViewController) {
                                      
                                      [self checkIfNavigationController:navigationController hasVCs:@[self.vc1]];
                                      self.preparationBlockCalled = YES;
                                      
                                  }
                                   completion:pushRemainingVCsTestBlock];
}

- (void)checkIfNavigationController:(UINavigationController *)navigationController hasVCs:(NSArray *)vcs
{
    XCTAssertEqual(navigationController.viewControllers.count, vcs.count, @"Expected %u view controllers in nav stack, but there are %u.", vcs.count, navigationController.viewControllers.count);
    for ( int i = 0; i < navigationController.viewControllers.count; i++ ) {
        UIViewController *navStackVC = navigationController.viewControllers[i];
        UIViewController *expectedVC = vcs[i];
        XCTAssertEqual(navStackVC, expectedVC, @"Expected %@ but found %@.", expectedVC.title, navStackVC.title);
    }
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    XCTAssert(self.preparationBlockCalled, @"navigationController:willShowViewController:animated: called before preparation block finished.");
    self.preparationBlockCalled = NO;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    XCTAssert(!self.completionBlockCalled, @"navigationController:didShowViewController:animated: called after completion block finished.");
    self.preparationBlockCalled = YES;
}

@end