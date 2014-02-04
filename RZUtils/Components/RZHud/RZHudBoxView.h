//
//  RZHudBoxView.h
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
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

typedef enum {
    RZHudBoxStyleInfo,
    RZHudBoxStyleLoading,
    RZHudBoxStyleProgress  // not implemented yet
} RZHudBoxStyle;

@interface RZHudBoxView : UIView

/// @name style
@property (nonatomic, assign) RZHudBoxStyle style;

/// @name Appearance Properties
@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat shadowAlpha;

@property (nonatomic, copy)   NSString *labelText;

// These are assign becuase they are overridden
@property (nonatomic, assign) UIColor *labelColor;
@property (nonatomic, assign) UIFont *labelFont;
@property (nonatomic, assign) UIColor *spinnerColor;

- (id)initWithStyle:(RZHudBoxStyle)style color:(UIColor*)color cornerRadius:(CGFloat)cornerRadius;

@end
