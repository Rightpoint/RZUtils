//
//  RZProgressView.h
//  Raizlabs
//
//  Created by Zev Eisenberg on 4/2/14.

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

/**
 *  The styles permitted for the progress bar.
 */
typedef NS_ENUM(NSInteger, RZProgressViewStyle) {
    /**
     *  The standard progress-view style. This is the default.
     */
    RZProgressViewStyleDefault,
    /**
     *  The style of progress view that is used in a toolbar.
     */
    RZProgressViewStyleBar
};

@interface RZProgressView : UIView

/**
 *  Initializes and returns a progress view object.
 *
 *  @param style A constant that specifies the style of the object to be created. See RZProgressViewStyle for descriptions of the style constants.
 *
 *  @return An initialized RZProgressView object or nil if the object couldn’t be created.
 */
- (instancetype)initWithProgressViewStyle:(RZProgressViewStyle)style; // sets the view height according to the style

/**
 *  The current graphical style of the receiver.
 */
@property (nonatomic) RZProgressViewStyle progressViewStyle; // default is RZProgressViewStyleDefault

/**
 *  The current progress shown by the receiver. Values range from 0.0 to 1.0. The default value is 0.0. Values outside the range are pinned.
 */
@property (nonatomic) float progress;

/**
 *  The color shown for the portion of the progress bar that is filled.
 */
@property (strong, nonatomic) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;

/**
 *  The color shown for the portion of the progress bar that is not filled.
 */
@property (strong, nonatomic) UIColor *trackTintColor UI_APPEARANCE_SELECTOR;

/**
 *  An image to use for the portion of the progress bar that is filled.
 */
@property (strong, nonatomic) UIImage *progressImage UI_APPEARANCE_SELECTOR;

/**
 *  An image to use for the portion of the track that is not filled.
 */
@property (strong, nonatomic) UIImage *trackImage UI_APPEARANCE_SELECTOR;

/**
 *  Adjusts the current progress shown by the receiver, optionally animating the change.
 *
 *  @param progress The new progress value.
 *  @param animated YES if the change should be animated, NO if the change should happen immediately.
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
