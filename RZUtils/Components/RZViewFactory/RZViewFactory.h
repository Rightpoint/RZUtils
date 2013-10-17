//
//  RZViewFactory.h
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (RZViewFactory)
+ (UIView *)view;
@end

@interface RZViewFactory : NSObject {
    UIView *_view;
}

@property (nonatomic, strong) IBOutlet UIView *view;

+ (UIView *)viewWithNibNamed:(NSString *)nibName;

@end
