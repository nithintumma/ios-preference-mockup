//
//  LoginViewController.m
//  Mockup
//
//  Created by Nithin Tumma on 6/6/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPushed:(id)sender {
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // login Facebook User
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
         [_activityIndicator stopAnimating];
         if (!user) {
             if (!error) {
                 NSLog(@"User cancelled facebook login");
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Log in Error"
                                                                 message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                 [alert show];
                 
             } else {
                 NSLog (@"Error occured");
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                 [alert show];
             }
         } else if (user.isNew) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Log In"
                                                             message:@"Good stuff." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
             [alert show];
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Returning User"
                                                             message:@"Got it to work" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
             [alert show];
             [self performSegueWithIdentifier:@"loginToHomeScreen" sender: self];
             
         }
         
         
     }];
    [_activityIndicator startAnimating];

}
@end
