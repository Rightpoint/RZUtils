//
//  STLoadingBlackView.h
//  ThumbSurveys
//
//  Created by Sebastian Trujillo on 3/26/09.
//  Copyright 2009 hypnoticmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STShowLoading() [RZHUD showLoading]
#define STShowLoadingWithMessage(msg) [RZHUD showLoadingWithMessage:msg]
#define STHideLoading() [RZHUD hideLoading]

typedef enum {
	STLoadingViewStateFadeIn,
	STLoadingViewStateShow,
	STLoadingViewStateFadeOut
} STLoadingViewState;

@class RZHUD;



@interface RZHUD : UIView {
	UIImageView *background;
	NSString *text;
	UILabel *_label;
	UIActivityIndicatorView *_spinner;
	STLoadingViewState _state;
	float fadeOutAnimationDuration;
}

@property (nonatomic, retain) UIImageView *background;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UILabel *_label;
@property (nonatomic, retain) UIActivityIndicatorView *_spinner;
@property (nonatomic) STLoadingViewState _state;
@property (nonatomic) float fadeOutAnimationDuration;

- (id)initWithText:(NSString *)newText;
- (void)fadeIn;
- (void)fadeOut;
- (void)_fadeIn:(CGContextRef)ctx;
- (void)_fadeOut:(CGContextRef)ctx;

+ (void)showLoading;
+ (void)showLoadingInWindow:(UIWindow*)win;
+ (void)showLoadingWithMessage:(NSString *)msg;
+ (void)showLoadingWithMessage:(NSString *)msg inWindow:(UIWindow*)win;
+ (float)hideLoading;

@end
