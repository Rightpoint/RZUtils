//
//  RZMapViewLocation.h
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RZMapViewLocationDelegate;

@interface RZMapViewLocation : UIView

@property (retain, nonatomic) NSString *locationName;
@property (retain, nonatomic) NSString *locationId;
@property (assign, nonatomic, readonly) CGFloat x;
@property (assign, nonatomic, readonly) CGFloat y;
@property (assign, nonatomic, readonly) CGFloat width;
@property (assign, nonatomic, readonly) CGFloat height;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) id<RZMapViewLocationDelegate> delegate;

+ (RZMapViewLocation*)mapViewLocationWithRect:(CGRect)rect name:(NSString*)name locationId:(NSString*)locationId delegate:(id<RZMapViewLocationDelegate>)delegate;
+ (RZMapViewLocation*)mapViewLocationWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height name:(NSString*)name locationId:(NSString*)locationId delegate:(id<RZMapViewLocationDelegate>)delegate;

- (id)initWithRect:(CGRect)rect name:(NSString*)name locationId:(NSString*)locationId;

@end

@protocol RZMapViewLocationDelegate <NSObject>

@end
