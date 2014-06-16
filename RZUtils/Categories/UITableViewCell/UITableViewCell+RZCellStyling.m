//
//  UITableViewCell+RZCellStyling.m
//
//  Created by Joshua Leibsly on 4/22/13.

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

#import "UITableViewCell+RZCellStyling.h"
#import "UIImage+RZStretchHelpers.h"

@implementation UITableViewCell (RZCellStyling)

- (void)rz_setBackgroundImagesForIndex:(int)index totalRowsInSection:(int)totalRows
{
    NSString *unselectedImageName = nil;
    NSString *selectedImageName = nil;
    
    // Single Cell
    if ( totalRows == 1 ) {
        unselectedImageName = @"bg-cell";
        selectedImageName = @"bg-cell-pressed";
    }
    // Top Cell
    else if ( index == 0 ) {
        unselectedImageName = @"bg-cell-top";
        selectedImageName = @"bg-cell-top-pressed";
    }
    // Bottom Cell
    else if ( index == totalRows - 1 ) {
        unselectedImageName = @"bg-cell-bottom";
        selectedImageName = @"bg-cell-bottom-pressed";
    }
    // Middle Cell
    else {
        unselectedImageName = @"bg-cell-middle";
        selectedImageName = @"bg-cell-middle-pressed";
    }
    
    // Regular Image
    UIImage *backgroundImage = [[UIImage imageNamed:unselectedImageName] rz_stretchableVersion];
    
    // Pressed Image
    UIImage *selectedImage = [[UIImage imageNamed:selectedImageName] rz_stretchableVersion];
    
    if ( [self.backgroundView isKindOfClass:[UIImageView class]] ) {
        [(UIImageView*)self.backgroundView setImage:backgroundImage];
    }
    else {
        UIView *backgroundStretchedView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self setBackgroundView:backgroundStretchedView];
    }
    
    if ( [self.selectedBackgroundView isKindOfClass:[UIImageView class]] ) {
        [(UIImageView*)self.selectedBackgroundView setImage:selectedImage];
    }
    else  {
        UIView *selectedStretchedView = [[UIImageView alloc] initWithImage:selectedImage];
        [self setSelectedBackgroundView:selectedStretchedView];
    }
}

@end
