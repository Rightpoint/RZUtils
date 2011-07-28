//
//  StarRatingSlider.h
//  BzzAgent
//
//  Created by Joe Goullaud on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarRatingSlider : UIView

@property (nonatomic, retain) UIImage *filledStarImage;
@property (nonatomic, retain) UIImage *emptyStarImage;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, assign) NSInteger maxStars;

@end
