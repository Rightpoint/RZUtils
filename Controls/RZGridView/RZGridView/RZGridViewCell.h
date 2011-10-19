//
//  RZGridViewCell.h
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RZGridViewCellStyleDefault
} RZGridViewCellStyle;

@interface RZGridViewCell : UIView {
    
}

@property (copy, readonly, nonatomic) NSString *reuseIdentifier;

@property (retain, readonly, nonatomic) UIImageView *imageView;
@property (retain, readonly, nonatomic) UIView *contentView;

- (id)initWithStyle:(RZGridViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
