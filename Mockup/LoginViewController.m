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
#import "PaveAPIClient.h"
#import "AFNetworking.h"


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
    if (session.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Already in");
        
        //now opens connection
        [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"In login block");
            [FBSession setActiveSession:session];
            if (status == FBSessionStateOpen) {
                
                
                
                NSLog(@"Open?: ");
                NSLog(session.isOpen ? @"Yes" : @"No");
                NSString* accessToken = session.accessToken;
                
                
                // keep for Push Notifications
                [KCSUser loginWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                    
                    NSLog(@"Finished login");
                    
                    NSLog(@"Accesstoken: %@", accessToken);
                    
                    [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
                }];
                
                
            }
            else
            {
                NSLog(@"something happened");
                NSLog(@"Some other status: %@", status);
            }
        }];
        
    }
    else
    {
        NSLog(@"Not open yet, so not skipping login");        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// checks both instance variables to see if the requests went through
-(void) sendSaveUserAndFacebookInformation
{
    if (self.didCompleteProfileInformation && self.didCompleteFriendsInformation) {
        // use the singleton APIClient
        NSLog(@"about to request user");
        
        NSData *jsonProfile = [NSJSONSerialization dataWithJSONObject:self.userProfile options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonProfileString = [[NSString alloc] initWithData:jsonProfile encoding:NSUTF8StringEncoding];
        
        NSData *jsonFriends = [NSJSONSerialization dataWithJSONObject:self.friendIds options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonFriendsString = [[NSString alloc] initWithData:jsonFriends encoding:NSUTF8StringEncoding];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: self.userProfile[@"facebookId"], @"id_facebookID", jsonProfileString,  @"id_profile", jsonFriendsString, @"id_friends",   nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.friendIds forKey:@"friends"];
        [defaults setObject:self.userProfile forKey:@"profile"];
        [defaults synchronize];

        [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
        
        
        //NSLog(@"%@", self.userProfile);
        //NSLog(@"%@",  jsonString);
        NSLog(@"Initialized friends as %@", self.friendIds);
        //NSLog(@"%@", [NSJSONSerialization dataWithJSONObject:self.friendIds options:nil error:nil]);
        [[PaveAPIClient sharedClient] postPath:@"/data/newuser"
        //                            parameters:@{@"id_facebookID":self.userProfile[@"facebookId"], @"id_profile": self.userProfile, @"friends": self.friendIds} success:^(AFHTTPRequestOperation *operation, id JSON) {
                                      parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
                                        NSLog(@"successfully logged in user to Django");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error logging in user to Django %@", error);
        }];
         
    }
}

- (void) initializeFacebookInformation
{
    self.didCompleteProfileInformation = NO;
    self.didCompleteFriendsInformation = NO;
    // get basic user information and
    FBRequest *request = [FBRequest requestForMe];
    
    // add gender and name to the query
    NSString *query =    
    @"SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
    
    NSString *query2 =
    @"SELECT (uid, gender, name) FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER BY mutual_friend_count DESC";
    
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
                                  NSLog(@"Error while getting facebook friends, retry");
                              } else {
                                 self.friendIds = [[NSMutableArray alloc] initWithCapacity: [result count]];
                                  
                                  NSArray *parsed = result[@"data"];
                                  for(id object in parsed)
                                  {
                                      [self.friendIds addObject: object[@"uid"]];
                                  }
                                  
                                  self.didCompleteFriendsInformation = YES;
                                  [self sendSaveUserAndFacebookInformation];
                                  
                                  // need to save the active user's values
                                  /*
                                  [[KCSUser activeUser] setValue: ids forAttribute: @"friends"];
                                  [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                                      NSLog(@"shit happens");
                                  }]; */
                                  
                              }
                          }];

    // set a property and call a method to check both properties
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
           self.userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            if (facebookID) {
                self.userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                self.userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                self.userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                self.userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                self.userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                self.userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                self.userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            self.didCompleteProfileInformation = YES;
            [self sendSaveUserAndFacebookInformation];
            
            //[[KCSUser activeUser] setValue: userProfile forAttribute: @"profile"];
                        
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
    
    [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [FBSession setActiveSession:session];
        if (status == FBSessionStateOpen) {
            NSString* accessToken = session.accessToken;
            /**
            [KCSUser loginWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                NSLog(@"Finished login");
                
                NSLog(@"Accesstoken: %@", accessToken);
                
                //saves and updates data
                [self initializeFacebookInformation];
                [self performSegueWithIdentifier:@"loginToHomeScreen" sender:self];
            }];
             */
            NSLog(@"Finished login");
            
            NSLog(@"Accesstoken: %@", accessToken);
            
            //saves and updates data
            [self initializeFacebookInformation];
            
            
        }
        else
        {
            NSLog(@"Some other status: %u", status);
        }
    }];
    NSLog(@"Exited block");
    [_activityIndicator startAnimating];
}
@end
