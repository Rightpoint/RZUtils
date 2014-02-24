//
//  RZSegmentViewController.h
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

#import <UIKit/UIKit.h>

@protocol RZSegmentViewControllerDelegate <NSObject>
@optional
- (void)willSelectSegmentAtIndex:(NSUInteger)index currentIndex:(NSUInteger)currentIndex;
- (void)didSelectSegmentAtIndex:(NSUInteger)index;

@end

@interface RZSegmentViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControl;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animationTransitioning;
#endif

@property (nonatomic, copy) NSArray *viewControllers;

// Changing this will select the VC at that index
@property (nonatomic, assign) NSUInteger selectedIndex;


// whether child view-controllers are allowed to scroll underneath the segmented view
@property (nonatomic, assign) BOOL shouldSegmentedControlOverlapContentView; 

@property (weak) id <RZSegmentViewControllerDelegate> delegate;

- (IBAction)segmentControlValueChanged:(id)sender;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end
