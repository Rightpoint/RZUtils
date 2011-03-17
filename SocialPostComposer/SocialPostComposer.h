//
//  StreamPoster.h
//  RZUtils
//
//  Created by Robert Sesek on 7/29/09.
//  Copyright 2009 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialPostComposerDelegate;

typedef enum _SocialPostComposerFlags
{
	SocialPostComposerFlagsUnconfigured = 0,
	SocialPostComposerFlagsText		= (1 <<  0),
	SocialPostComposerFlagsImage	= (1 <<  1),
	//--Currently unused------------------------
	SocialPostComposerFlagsLink		= (1 <<  2),
	SocialPostComposerFlagsAudio	= (1 <<  3),
	SocialPostComposerFlagsVideo	= (1 <<  4),
	SocialPostComposerFlagsGPS		= (1 <<  5),
	//------------------------------------------
} SocialPostComposerFlags;

// SocialPostComposer is a UIViewController that displays a status posting box.
// It can be configured to allow posting of text, picture, and in the future
// audio, video, and link updates.
//
// This class does NOT handle any of the actual form post code, but rather will
// return to its delegate a dictionary of all the data the user has entered.
//
// The view is configured by bitwise-OR-ing SocialPostComposerFlags and setting
// the |flags| property.

@interface SocialPostComposer : UIViewController <UINavigationControllerDelegate, 
												 UIImagePickerControllerDelegate,
												 UITextViewDelegate>
{
	SocialPostComposerFlags flags;
	id <SocialPostComposerDelegate> delegate;
	
	// UI customization.
	NSInteger maxTextLength; // Max length for text status. <=0 for no limit.
	UIColor* themeColor; // Color to tint |toolbar|. Nil for default black.
	NSString* navTitle; // Title to display at the top of the posting UI.
	IBOutlet UIView* backgroundView; // Background UIView. Add subviews to this.
	
	
	// Navigation bar.
	IBOutlet UINavigationBar* navBar;
	IBOutlet UINavigationItem* navItem;
	
	// Toolbar items.
	IBOutlet UIToolbar* toolbar;
	UIBarButtonItem* toolbarCamera;
	UIBarButtonItem* toolbarCharCount;
	
	// The text view into which the user types their message.
	NSString* defaultText; // The default text for |textView|.
	IBOutlet UITextView* textView;
	IBOutlet UIImageView* textViewBox;
	
	// Image view which will display the image the user selected.
	UIImagePickerController* imagePicker;
	IBOutlet UIImageView* imageView;
	NSString* defaultImagePath;			// the default image (if the picker is not used)
		
	// Button that will initiate the post.
	IBOutlet UIBarButtonItem* postButton;
	
	// A temporary string used to hold on to the entered text while the photo
	// picker is up.
	NSString* temporaryText;
	
	// maximum dimension the image can be. Used when resizing the image
	int maxImageDimension;
	
	// flag indicating whether to resize the image. 
	BOOL resizeImage;
	
	// activity indicator used when an image is resizing. 
	IBOutlet UIActivityIndicatorView* resizingIndicator;
}

@property (readwrite) SocialPostComposerFlags flags;
@property (assign) id <SocialPostComposerDelegate> delegate;
@property NSInteger maxTextLength;
@property (retain) UIColor* themeColor;
@property (copy) NSString* navTitle;
@property (copy) NSString* defaultText;
@property (copy) NSString* defaultImagePath;
@property (readonly) UIView* backgroundView;
@property int maxImageDimension;
@property BOOL resizeImage;

// Designated initializer.
- (id)init;

// Lays out the toolbar with a button configuration based on |flags|.
- (void)layoutToolbar;

// These actions are forwarded to the delegate.
- (IBAction)cancelPressed:(id)sender;
- (IBAction)postPressed:(id)sender;

@end

//------------------------------------------------------------------------------

// These constans are used in the dictionary for |-socialPostComposer:posted:|.
extern NSString* const SocialPostText;
extern NSString* const SocialPostImage;
//--Currently undefined----------------------
extern NSString* const SocialPostLink;
extern NSString* const SocialPostAudio;
extern NSString* const SocialPostVideo;
extern NSString* const SocialPostGPSLocation;
//-------------------------------------------

@protocol SocialPostComposerDelegate <NSObject>
@optional

// The cancel button was pressed; the delegate should dismiss the controller.
- (void)socialPostComposerCancelled:(SocialPostComposer*)composer;

// Called when the post button is pressed. Returned is an NSDictionary containg
// items with the above keys.
- (void)socialPostComposer:(SocialPostComposer*)composer posted:(NSDictionary*)item;

// If SPC is configured with SocialPostComposerFlagsImage, this is called after
// an image has been selected and resized and the UI updated. The |image| param
// will also be returned to the delegate in |-socialPostComposer:posted:|.
- (void)socialPostComposer:(SocialPostComposer*)composer selectedImage:(UIImage*)image;

@end
