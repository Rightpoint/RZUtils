//
//  RZLoginViewController.h
//  RZUtils
//
//  Created by jkaufman on 1/20/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RZLoginViewControllerDelegate <NSObject>
- (void)loginViewDidCancel;
- (void)loginViewDidFinishWithUser:(NSString *)user password:(NSString *)password;
@end

@interface RZLoginViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UIImageView		*_background;
	IBOutlet UILabel			*_loginPrompt;
	IBOutlet UITextField		*_username;
	IBOutlet UITextField		*_password;
	IBOutlet UIButton			*_cancel;
	IBOutlet UIButton			*_login;
	
	id <RZLoginViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id <RZLoginViewControllerDelegate> delegate;
@property (readonly) IBOutlet UILabel* loginPrompt;
@property (readonly) IBOutlet UITextField* username;
@property (readonly) IBOutlet UITextField* password;

- (id)initWithDelegate:(id <RZLoginViewControllerDelegate>)delegate;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)loginButtonpressed:(id)sender;
- (void)dismissKeyboard;

@end
