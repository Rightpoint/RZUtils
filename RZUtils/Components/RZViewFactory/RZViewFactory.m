//
//  RZViewFactory.m
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZViewFactory.h"

@implementation UIView (RZViewFactory)

+ (instancetype)rz_loadFromNibNamed:(NSString *)nibNameOrNil
{
    // assume name is same as class if nil
    NSString *nibName = nibNameOrNil ? nibNameOrNil : NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

@end