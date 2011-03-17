//
//  RZLoginViewController.m
//  RZUtils
//
//  Created by jkaufman on 1/20/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "RZLoginViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RZLoginViewController

@synthesize delegate = _delegate;
@synthesize loginPrompt = _loginPrompt;
@synthesize username = _username;
@synthesize password = _password;

- (id)initWithDelegate:(id <RZLoginViewControllerDelegate>)delegate
{
	if (self = [super initWithNibName:@"LoginView" bundle:nil]) {
		self.delegate = delegate;
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_background.layer.cornerRadius = 10;
	
	[_username becomeFirstResponder];
	_login.enabled = (_username.text && _password.text);
}

- (void)dismissKeyboard
{
	[_username resignFirstResponder];
	[_password resignFirstResponder];
}

- (void)viewDidUnload
{
	_background		= nil;
	_loginPrompt	= nil;
	_username		= nil;
	_password		= nil;
	_cancel			= nil;
	_login			= nil;
}

#pragma mark Actions
- (IBAction)cancelButtonPressed:(id)sender
{
	if ([_delegate respondsToSelector:@selector(loginViewDidCancel)])
		[_delegate loginViewDidCancel];
}

- (IBAction)loginButtonpressed:(id)sender
{
	if ([_delegate respondsToSelector:@selector(loginViewDidFinishWithUser:password:)])
		[_delegate loginViewDidFinishWithUser:_username.text password:_password.text];	
}

#pragma mark UITextField Support
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// Ensure that both username and password are entered
	NSString *_newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

	BOOL valid;
	if (NO == [_newText isEqualToString:@""]) {
		if (textField == _password && NO == [[_username text] isEqualToString:@""])
			valid = YES;
		else if(NO == [[_password text] isEqualToString:@""])
			valid = YES;
	}

	_login.enabled = valid;
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	_login.enabled = NO;
	return YES;
}

@end
