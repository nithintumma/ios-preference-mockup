//
//  LoginViewController.m
//  Mockup
//
//  Created by Nithin Tumma on 6/6/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "ViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Log In";
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeFacebookInformation
{
    // get basic user information and 
    FBRequest *request = [FBRequest requestForMe];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (!error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity: [friends count]];
        
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [ids addObject: friend.id];
        }
            
        [[PFUser currentUser] setObject:ids forKey:@"friends"];
        [[PFUser currentUser] saveInBackground];
        } else {
            NSLog(@"Error while getting facebook friends");
        }
        
    }];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            // dict to hold data
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];

}

- (IBAction)loginButtonTouch:(id)sender {
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
             // set up the facebook init
             [self initializeFacebookInformation];
             [self performSegueWithIdentifier:@"loginToHomeScreen" sender: self];
         } else {
             // returning user should be stored in the database
             [self performSegueWithIdentifier:@"loginToHomeScreen" sender: self];
         }
     }];
    [_activityIndicator startAnimating];
}
@end
