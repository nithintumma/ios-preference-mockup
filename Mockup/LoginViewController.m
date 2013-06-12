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
#import "AppDelegate.h"
#import <KinveyKit/KinveyKit.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Log In";
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    // chech if session is open
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = delegate.session;
    
    NSLog(@"Session is: %@", session);
    NSLog(@"Session is: %@", FBSession.activeSession);
    
    // if the session isn't open, let's open it now and present the login UX to the user
    //if (!FBSession.activeSession.isOpen) {
    if (session.state == FBSessionStateCreatedTokenLoaded || session.state == FBSessionStateOpen || session.state == FBSessionStateOpenTokenExtended) {
        NSLog(@"Already in");
        [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
    }
    else
    {
        NSLog(@"Not open yet, so not skipping login");        
    }
    
    /*if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
    }*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void) initializeFacebookInformation
{

    // get basic user information and
    FBRequest *request = [FBRequest requestForMe];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = [delegate session];
    request.session = session;
    //NSString* accessToken = session.accessToken;
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    NSString *query =
    //@"SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
    [NSString stringWithFormat: @"(SELECT name FROM user WHERE uid = me())"];
    //query = [query stringByAppendingString:accessToken];

    NSLog(@"FB active session : ");
    NSLog([FBSession activeSession].isOpen ? @"Yes" : @"No");
    
    // Set up the query parameter
    //NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"queries", nil];
    NSDictionary *queryParam = [NSDictionary dictionaryWithObject:query forKey:@"queries"];

    // Make the API request that uses FQL
    //[FBRequestConnection startWithGraphPath:@"/fql"
    //                             parameters:queryParam
    //                             HTTPMethod:@"GET"
    //                    completionHandler:^(FBRequestConnection *connection,
    FBRequestConnection *conn = [[FBRequestConnection alloc] init];
    
    //FBRequest *fql1 = [[FBRequest alloc] initWithSession:session graphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    FBRequest *fql1 = [FBRequest requestForMyFriends];
    fql1.session = session;

    [conn addRequest:fql1 completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"connection data");
                                  NSLog(@"%@", fql1);
                                  NSLog(@"Error while getting facebook friends %@",error);
                              } else {
                                  //creates a dict of ids
                                  NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity: [result count]];
                                  
                                  NSArray *parsed = result[@"data"];
                                  for(id object in parsed)
                                  {
                                      //NSLog(@"Current: %@", object);
                                      [ids addObject: object[@"uid"]];
                                  }
                                  
                                  //NSLog(@"IDs: %@", ids);
                                  
                                  //saves
                                  [[KCSUser activeUser] setValue: ids forKey: @"friends"];
                                  [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray * objectsOrNil, NSError * errorOrNil) {
                                        if (errorOrNil != nil) {
                                            NSLog(@"Error in saving new user");
                                        }
                                        else
                                        {
                                            NSLog(@"Successfully updated user");
                                        }
                                  }];
                                  //[[PFUser currentUser] setObject:ids forKey:@"friends"];
                                  //[[PFUser currentUser] saveInBackground];
                                  
                              }
                          }];
   
                       
    [conn addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            NSLog(@"downloaded user data %@", result);
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
            
            //figure out how to update
            [[KCSUser activeUser] setValue: userProfile forKey: @"profile"];
            [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray *objectsOrNil, NSError * errorOrNil) {
                if (errorOrNil != nil) {
                    NSLog(@"Error in saving user profile");
                }
                else
                {
                    NSLog(@"Successfully saved user profile");
                }
            }];
            
            //[[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            //[[PFUser currentUser] saveInBackground];
            
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        }
            
        else {
            NSLog(@"Some other error: %@", error);
        }
    }];
                   
    //starts request
    [conn start];
    
}
*/

- (void) initializeFacebookInformation
{
    NSLog(@"init Facebook Information");
    // get basic user information and
    FBRequest *request = [FBRequest requestForMe];
    NSString *query =
    @"SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
    // Set up the query parameter
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error while getting facebook friends");
                              } else {
                                  //creates a dict of ids
                                  NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity: [result count]];
                                  
                                  NSArray *parsed = result[@"data"];
                                  for(id object in parsed)
                                  {
                                      //NSLog(@"Current: %@", object);
                                      [ids addObject: object[@"uid"]];
                                  }
                                  
                                  //NSLog(@"IDs: %@", ids);
                                  
                                  //saves
                                  NSLog(@"Friend IDs: %@", ids);
                                  
                                  
                                  [[KCSUser activeUser] setValue: ids forAttribute: @"friends"];
                                  [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                      NSLog(@"shit happens");
                                  }];
                                   
                                  
                                  
                                  //[[PFUser currentUser] setObject:ids forKey:@"friends"];
                                  //[[PFUser currentUser] saveInBackground];
                                  
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
            [[KCSUser activeUser] setValue: userProfile forAttribute: @"profile"];
            
            NSLog(@"Profile: %@", userProfile);
            //[[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            //[[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}



- (IBAction)loginButtonTouch:(id)sender {
    
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = [delegate session];
    
    NSLog(@"About to login");
    // login Facebook User
    
    
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"In login block");
        [FBSession setActiveSession:session];
        if (status == FBSessionStateOpen) {
            NSLog(@"Open?: ");
            NSLog(session.isOpen ? @"Yes" : @"No");
            NSString* accessToken = session.accessToken;
            [KCSUser loginWithWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                NSLog(@"Finished login");
                
                NSLog(@"Accesstoken: %@", accessToken);

                
                //saves and updates data
                [self initializeFacebookInformation];
                
                [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
            }];
        }
        else
        {
            NSLog(@"something happened");
            NSLog(@"Some other status: %@", status);
        }
    }];
    NSLog(@"Exited block");
    [_activityIndicator startAnimating];
    /*
    [FBSession openActiveSessionWithPermissions:permissionsArray allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"called");
        switch (status) {
            case FBSessionStateOpen: {
                NSLog(@"Open?: ");
                NSLog([FBSession activeSession].isOpen ? @"Yes" : @"No");
                NSString* accessToken = session.accessToken;
                [KCSUser loginWithWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                    NSLog(@"Finished login");
                    
                    NSLog(@"Accesstoken: %@", accessToken);
                    //[FBSession setActiveSession:session];
                    
                    //saves and updates data
                    [self initializeFacebookInformation];
                    
                    [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
                }];
                break;
            }
            case FBSessionStateClosed:
                NSLog(@"closed");
                break;
            case FBSessionStateCreated:
                NSLog(@"created");
                break;
            case FBSessionStateCreatedOpening:
                NSLog(@"opening");
                break;
            case FBSessionStateClosedLoginFailed:
                NSLog(@"failed");
                break;
            case FBSessionStateOpenTokenExtended:
                NSLog(@"extended");
                break;
            case FBSessionStateCreatedTokenLoaded:
                NSLog(@"loaded");
                break;
        }
        
    }];
    */ 
    /*
    [FBSession openActiveSessionWithPermissions:permissionsArray allowLoginUI:YES completionHandler:^(FBSession *session,
                                         FBSessionState status,
                                         NSError *error) {
        NSLog(@"In login block");
        if (status == FBSessionStateOpen) {
            NSLog(@"Open?: ");
            NSLog([FBSession activeSession].isOpen ? @"Yes" : @"No");
            NSString* accessToken = session.accessToken;
            [KCSUser loginWithWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                NSLog(@"Finished login");
                
                NSLog(@"Accesstoken: %@", accessToken);
                //[FBSession setActiveSession:session];
                
                //saves and updates data
                [self initializeFacebookInformation];
                
                [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
            }];
        }
        else
        {
            NSLog(@"something happened");
            NSLog(@"Some other status: %@", status);
        }
    }];
    NSLog(@"Exited block");
    [_activityIndicator startAnimating];
*/
}
@end
