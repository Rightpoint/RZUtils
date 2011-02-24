    //
//  FontViewController.m
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/12/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "FontViewController.h"


@implementation FontViewController
@synthesize pickerView = _pickerView ;
@synthesize delegate = _delegate;
@synthesize selectedFont = _selectedFont;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSMutableArray* fonts = [[NSMutableArray alloc] initWithCapacity:100];
	
	// construct the list of font names
	NSArray* fontFamilyNames = [UIFont familyNames];
	for (NSString* familyName in fontFamilyNames)
	{
		NSArray* fontNames = [UIFont fontNamesForFamilyName:familyName];
		[fonts addObjectsFromArray:fontNames];
	}
	
	_fontNames = [fonts retain];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	
	self.pickerView = nil;
	
	[_fontNames release];
	
    [super dealloc];
}

-(void) setSelectedFont:(UIFont *)font
{
	[_selectedFont release];
	_selectedFont = [font retain];
	
	NSString* fontName = font.fontName;
	
	int index = [_fontNames indexOfObject:fontName];
	[_pickerView selectRow:index inComponent:0 animated:NO];
	
	index = [_selectedFont pointSize];
	[_pickerView selectRow:index inComponent:1 animated:NO];
}

#pragma mark UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2; // font name and size. 
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger itemCount = 0;
	
	if (component == 0) {
		itemCount =  _fontNames.count;
	}
	else {
		itemCount = 99;
	}


	return itemCount;
	

}

#pragma mark UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UIView* viewForRow = nil;
	
	if (component == 0)
	{
		
		UILabel* label = nil;
		if(nil != view)
		{
			label = (UILabel*)view;
		}
		else 
		{
			label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 40)] autorelease];
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = UITextAlignmentCenter;
		}
		
		NSString* fontName = [_fontNames objectAtIndex:row];

		label.font = [UIFont fontWithName:fontName size:24];
		label.text = fontName;
		
		viewForRow = label;

	}
	else 
	{
		UILabel* label = nil;
		if(nil != view)
		{
			label = (UILabel*)view;
		}
		else 
		{
			label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)] autorelease];
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = UITextAlignmentCenter;
		}
		
		label.text = [NSString stringWithFormat:@"%d", row];

		viewForRow = label;
	}

	
	return viewForRow;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat width = 20;
	
	if (component == 0) 
	{
		width = 400;
	}	
	else {
		width = 80;
	}

	
	return width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	CGFloat height = 40;
	
	if (component == 0) {
		height = 40;
	}
	
	return height;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString* fontName = nil;
	int fontSize = 24;
	
	if (component == 0) {
		fontName = [_fontNames objectAtIndex:row];
		fontSize = [_selectedFont pointSize];
	}
	else {
		fontName = [_selectedFont fontName];
		fontSize = row;
	}

	
	[_selectedFont release];
	_selectedFont = [[UIFont fontWithName:fontName size:fontSize] retain];
	
	if (_delegate)
	{
		[_delegate fontSelected:_selectedFont];
	}
}

@end
