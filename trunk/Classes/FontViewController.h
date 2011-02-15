//
//  FontViewController.h
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/12/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontViewControllerDelegate<NSObject>

-(void) fontSelected:(UIFont*)font;

@end

@interface FontViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	UIPickerView* _pickerView;
	
	NSArray* _fontNames;
	
	id<FontViewControllerDelegate> _delegate;
	
	UIFont* _selectedFont;
}

@property (nonatomic, retain) IBOutlet UIPickerView* pickerView;
@property (nonatomic, assign) id<FontViewControllerDelegate> delegate;
@property (nonatomic, retain) UIFont* selectedFont;

@end
