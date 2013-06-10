//
//  LoginViewController.h
//  Mockup
//
//  Created by Nithin Tumma on 6/6/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)loginButtonTouch:(id)sender;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL loggedIn;
@end
