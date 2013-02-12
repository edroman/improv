//
//  Copyright (c) 2012 Parse. All rights reserved.

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
