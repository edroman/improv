//
//  PlayStoryViewController.h
//  Improv
//
//  Created by Ed Roman on 1/19/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayStoryViewController : UIViewController<UITextFieldDelegate>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

@end
