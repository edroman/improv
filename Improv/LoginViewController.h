//
//  Copyright (c) 2012 Parse. All rights reserved.

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIScrollViewDelegate, UITextFieldDelegate>

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
