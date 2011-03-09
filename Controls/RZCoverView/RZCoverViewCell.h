//
//  RZCoverViewCell.h
//  IssueControl
//
//  Created by Joe Goullaud on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	RZCoverViewCellStyleDefault
} RZCoverViewCellStyle;


@interface RZCoverViewCell : UIControl {
	RZCoverViewCellStyle _style;
	NSString* _reuseIdentifier;
	UIImage* _image;
}

@property (readonly) RZCoverViewCellStyle style;
@property (nonatomic, retain) NSString* reuseIdentifier;
@property (nonatomic, retain) UIImage* image;

- (id)initWithStyle:(RZCoverViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;
- (void)updateImage:(UIImage*)image animated:(BOOL)animated;

@end
