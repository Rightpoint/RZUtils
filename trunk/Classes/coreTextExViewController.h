//
//  coreTextExViewController.h
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontViewController.h"

@class ColumnsView;

@interface coreTextExViewController : UIViewController <FontViewControllerDelegate> {
	
	ColumnsView* _columnsView;
	
	UIScrollView* _scrollView;
	
	NSMutableArray* _pageViews;
	
	NSMutableAttributedString* _text;
	
	UIFont* _selectedFont;
	
	UIPopoverController* popoverController;
}

@property (nonatomic, retain) IBOutlet ColumnsView* columnsView;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;

@property (nonatomic, retain) NSMutableAttributedString* text;
@property (nonatomic, retain) UIPopoverController* popoverController;


-(IBAction) minusPressed:(id)sender;
-(IBAction) plusPressed:(id)sender;
-(IBAction) fontPressed:(id)sender;


@end

