//
//  StreamPoster.m
//  RZUtils
//
//  Created by Robert Sesek on 7/29/09.
//  Copyright 2009 Raizlabs. All rights reserved.
//

#import <RZImageUtils/ImageUtils.h>
#import "SocialPostComposer.h"

#define kImageMaxSize 800

NSString* const SocialPostText	= @"SocialPostComposerItemText";
NSString* const SocialPostImage	= @"SocialPostComposerItemImage";

@implementation SocialPostComposer
@synthesize flags;
@synthesize delegate;
@synthesize maxTextLength;
@synthesize themeColor;
@synthesize navTitle;
@synthesize defaultText;
@synthesize defaultImagePath;
@synthesize backgroundView;
@synthesize maxImageDimension;
@synthesize resizeImage;

- (id)init
{
	if (self = [self initWithNibName:@"SocialPostComposer" bundle:nil])
	{
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.maxImageDimension = kImageMaxSize;
		self.resizeImage = NO;
	}
	
	return self;
}
- (void)dealloc 
{	
	[textView release];
	[imageView release];
	
	[themeColor release];
	[navTitle release];
	[defaultText release];
	[defaultImagePath release];
	
	// Release the toolbar.
	[toolbarCamera release];
	[toolbarCharCount release];
	
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self layoutToolbar];
	
	UIImage* image = textViewBox.image;
	textViewBox.image = [image stretchableImageWithLeftCapWidth:50 topCapHeight:50];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	toolbar.hidden = (orientation != UIInterfaceOrientationPortrait);
    return (orientation == UIInterfaceOrientationPortrait ||
			orientation == UIInterfaceOrientationLandscapeLeft ||
			orientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (flags == SocialPostComposerFlagsUnconfigured)
		[NSException raise:@"SocailPostComposerException" format:[NSString stringWithFormat:@"%@ is unconfigured", self]];
	
	[self layoutToolbar];
	
	// Set the title and color of the the navigation bar.
	navItem.title = navTitle;
	navBar.tintColor = themeColor;
	
	// Make the text view first responder to show the keyboard.
	[textView becomeFirstResponder];
	if ([temporaryText length] > 0)
		textView.text = [temporaryText autorelease];
	else
		textView.text = defaultText;
	temporaryText = nil;
	
	if (defaultImagePath != nil) {
		UIImage* image = [UIImage imageWithContentsOfFile:defaultImagePath];
		[resizingIndicator startAnimating];
		[self performSelectorInBackground:@selector(resizeImage:) withObject:image];
	}
}

- (void)layoutToolbar
{
	NSMutableArray* items = [NSMutableArray array];
	
	toolbar.tintColor = themeColor;
	
	// Camera button.
	if (flags & SocialPostComposerFlagsImage)
	{
		[toolbarCamera release];
		toolbarCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
		[items addObject:toolbarCamera]; 
	}
	
	// Character count.
	if (maxTextLength > 0)
	{
		UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
		[items addObject:spacer]; // Array takes ownership.
		[spacer release];
		
		[toolbarCharCount release];
		NSString* max = [NSString stringWithFormat:@"%d", maxTextLength];
		toolbarCharCount = [[UIBarButtonItem alloc] initWithTitle:max style:UIBarButtonItemStylePlain target:nil action:NULL];
		[items addObject:toolbarCharCount];
	}
	
	[toolbar setHidden:NO];
	if ([items count] < 1)
	{
		// hide the toolbar and stretch the beckground image view and text view to fill the missing space
		[toolbar setHidden:YES];
	
		CGRect originalRect = textViewBox.frame;
		textViewBox.frame = CGRectMake(originalRect.origin.x,
									   originalRect.origin.y,
									   originalRect.size.width,
									   originalRect.size.height + toolbar.frame.size.height / 2);
		originalRect = textView.frame;
		textView.frame = CGRectMake(originalRect.origin.x,
									originalRect.origin.y,
									originalRect.size.width,
									originalRect.size.height + toolbar.frame.size.height / 2);
	}
	
	[toolbar setItems:items];
	[toolbar setNeedsDisplay];
}

// this needs to be called on the main thread. 
-(void) updateImage:(UIImage*) image
{
	imageView.image = image;
	textView.frame = CGRectMake(textView.frame.origin.x, 
								textView.frame.origin.y, 
								textView.frame.size.width - imageView.frame.size.width, 
								textView.frame.size.height);
	[resizingIndicator stopAnimating];
}

// called in the background to resize an image. 
-(void) resizeImage:(UIImage*)image
{
	NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc] init];
	
	UIImage* resizedImage = [ImageUtils scaleAndRotateImage:image toMax:maxImageDimension];
	
	[self performSelectorOnMainThread:@selector(updateImage:) withObject:resizedImage waitUntilDone:YES];
	
	// if the delegate supports it, send it the resized image 
	if([delegate respondsToSelector:@selector(socialPostComposer:selectedImage:)])
	{
		[delegate socialPostComposer:self selectedImage:resizedImage];
	}
	
	[autorelease drain];
	[autorelease release];
}


#pragma mark Navigation Actions

- (IBAction)cancelPressed:(id)sender
{
	// Hide keyboard here, since delegate unable
	[textView resignFirstResponder];
	
	if ([delegate respondsToSelector:@selector(socialPostComposerCancelled:)])
		[delegate socialPostComposerCancelled:self];
}

- (IBAction)postPressed:(id)sender
{
	NSMutableDictionary* item = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[item setObject:textView.text forKey:SocialPostText];
//	[item setObject:imageView.image forKey:SocialPostImage];
	
	if (imageView.image)
		[item setObject:imageView.image forKey:SocialPostImage];
	
	if ([delegate respondsToSelector:@selector(socialPostComposer:posted:)])
		[delegate socialPostComposer:self posted:item];
}

#pragma mark Toolbar Actions

- (IBAction)cameraPressed:(id)sender
{
	temporaryText = [[NSString stringWithString:textView.text] retain];
	
	imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setAllowsImageEditing:NO];
	[imagePicker setDelegate:self];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	else
		return;
	
	[self presentModalViewController:imagePicker animated:YES];
}

#pragma mark UITextViewDelegate

// Update the remaining number of characters.
- (void)textViewDidChange:(UITextView*)tv
{
	if (maxTextLength > 0)
		toolbarCharCount.title = [NSString stringWithFormat:@"%d", maxTextLength - textView.text.length]; 
}

#pragma mark  UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	[imagePicker dismissModalViewControllerAnimated:YES];
	[textView becomeFirstResponder];
	
	NSLog(@"media info: %@", info);
	
	UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (originalImage)
	{
		// If no image had yet been set, resize the text view.
		if (!imageView.image)
		{
			// Resize the text view to exclude the width of the embedded image view. 
			textView.frame = CGRectMake(
				textView.frame.origin.x, 
				textView.frame.origin.y,
				textView.frame.size.width - imageView.frame.size.width,
				textView.frame.size.height
			);
		}
		
		if(resizeImage)
		{
			[resizingIndicator startAnimating];
			[self performSelectorInBackground:@selector(resizeImage:) withObject:originalImage];
		}
		else
			imageView.image = originalImage;
	}
	
	[imagePicker release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[imagePicker dismissModalViewControllerAnimated:YES];
	[textView becomeFirstResponder];
	[imagePicker release];
}

@end
