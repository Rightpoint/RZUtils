//
//  UITableViewCell+RZCellStyling.m
//
//  Created by Joshua Leibsly on 4/22/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "UITableViewCell+RZCellStyling.h"
#import "UIImage+RZStretchHelpers.h"

@implementation UITableViewCell (RZCellStyling)

- (void)setBackgroundImagesForIndex:(int)index totalRowsInSection:(int)totalRows
{
    NSString *unselectedImageName = nil;
    NSString *selectedImageName = nil;
    
    // single
    if (totalRows == 1)
    {
        unselectedImageName = @"bg-cell";
        selectedImageName = @"bg-cell-pressed";
    }
    
    // top
    else if (index == 0)
    {
        unselectedImageName = @"bg-cell-top";
        selectedImageName = @"bg-cell-top-pressed";
    }
    
    // bottom
    else if (index == totalRows - 1)
    {
        unselectedImageName = @"bg-cell-bottom";
        selectedImageName = @"bg-cell-bottom-pressed";
    }
    
    // middle
    else
    {
        unselectedImageName = @"bg-cell-middle";
        selectedImageName = @"bg-cell-middle-pressed";
    }
    
    //regular
    UIImage *backgroundImage = [[UIImage imageNamed:unselectedImageName] makeStretchable];
    
    //pressed
    UIImage *selectedImage = [[UIImage imageNamed:selectedImageName] makeStretchable];
    
    
    if ([self.backgroundView isKindOfClass:[UIImageView class]])
    {
        [(UIImageView*)self.backgroundView setImage:backgroundImage];
    }
    else
    {
        UIView *backgroundStretchedView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self setBackgroundView:backgroundStretchedView];
    }
    
    if ([self.selectedBackgroundView isKindOfClass:[UIImageView class]])
    {
        [(UIImageView*)self.selectedBackgroundView setImage:selectedImage];
    }
    else
    {
        UIView *selectedStretchedView = [[UIImageView alloc] initWithImage:selectedImage];
        [self setSelectedBackgroundView:selectedStretchedView];
    }
    
}

@end
