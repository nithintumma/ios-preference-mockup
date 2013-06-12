//
//  ViewController.m
//  Mockup
//
//  Created by Neel Patel on 6/3/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "ViewController.h"
#import "ToastAlert.h"
#import <Parse/Parse.h>
#import <KinveyKit/KinveyKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.front = 0;
    [PFImageView class];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UIPanGestureRecognizer *pangr2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UIPanGestureRecognizer *pangr3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.face addGestureRecognizer:pangr];
    [self.face2 addGestureRecognizer:pangr2];
    [self.face3 addGestureRecognizer:pangr3];
    
    [super viewDidLoad];
    
    //starts it off for the first time
    [self reloadIntoBackground];
    [self reloadIntoBackground];
    [self reloadIntoBackground];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
                
        UIView *draggedButton = recognizer.view;
        CGPoint translation = [recognizer translationInView:self.view];
        
        CGRect newButtonFrame = draggedButton.frame;
        //calculates a damping coefficient - the farther we are away from the center of the app, the more friction we will have (ranging from 0.5 to 1)        
        //assumes center at x=120,y=260 (wrong, but good enough for now)
        //x goes from -60 to 290, y goes from -40 to 430 (roughly, and once again wrong but good enough for now)
        //ranges roughly from 1 at the origin to 0.2 at the edge
        //NSLog(@"X coord: %f", newButtonFrame.origin.x);
        //NSLog(@"Y coord: %f", newButtonFrame.origin.y);
        
        float xdist = powf((1-(fabsf(120-newButtonFrame.origin.x)/180)*.3),2);
        float ydist = powf((1-(fabsf(260-newButtonFrame.origin.y)/250)*.3),2);
        
        //NSLog(@"X damp: %f", xdist);
        //NSLog(@"Y damp: %f", ydist);
        
        //newButtonFrame.origin.x += (translation.x*xdist);
        //newButtonFrame.origin.y += (translation.y*ydist);
        
        newButtonFrame.origin.x += (translation.x);
        newButtonFrame.origin.y += (translation.y);
                
        draggedButton.frame = newButtonFrame;
        
        //sets a slightly opaque checkmark over the right image
        
        //if we're on the top
        if(newButtonFrame.origin.y < 260)
        {
            self.leftCheck.alpha = 1.5 - xdist;
            self.rightCheck.alpha = 0;
        }
        else
        {
            self.leftCheck.alpha = 0;
            self.rightCheck.alpha = 1.5 - xdist;
        }
        
        
        [recognizer setTranslation:CGPointZero inView:self.view];        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {

        //if the action has ended, then we move back to the origin OR offscreen
        //the circle is 100 px wide, and the face is 80px wide. That means if the distance from the center of the circle to the center of the button is more than 90px (let's go with 150 though to have some room), go outwards. Else, return inwards
        //HOWEVER, we only really want to consider movement in the y-direction (I think...)
        UIView *draggedButton = recognizer.view;
        CGRect newButtonFrame = draggedButton.frame;
        
        //float dist = powf(120-newButtonFrame.origin.x,2) + powf(164-newButtonFrame.origin.y,2);
        float dist = powf(260-newButtonFrame.origin.y,2);

        
        NSLog(@"Distance: %f", dist);
        
        //if we're far away from the center, then keep same y and move to greater x side
        if(dist > 5000)
        {
            //if we're on top
            if(newButtonFrame.origin.y < 260)
            {
                newButtonFrame.origin.y = -80;
            }
            else
            {
                newButtonFrame.origin.y = 450;
            }
            draggedButton.frame = newButtonFrame;
            [self refresh];            
        }
        else
        {
            //resets checks
            self.leftCheck.alpha = 0;
            self.rightCheck.alpha = 0;
            
            newButtonFrame.origin.x = 120;
            newButtonFrame.origin.y = 260;
            draggedButton.frame = newButtonFrame;
        }
                

        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
}

int getRand(int max, int old) {
    NSInteger random = old;
    while(random == old)
    {
        random = arc4random() % max;
    }
    return random;
}

// gets a new friend and a new
-(void) reloadIntoBackground
{
    // set indicators to false
    self.profilePicDidLoad = NO;
    self.productsDidLoad = NO;
    
    // init the current image holder
    PFImageView *next_top = self.top;
    PFImageView *next_bottom = self.bottom;
    FBProfilePictureView *next_face = self.face;
    if (self.front == 0){
        next_top = self.top;
        next_bottom = self.bottom;
        next_face = self.face;
        
        // change the top image
        self.front = 1;
    }
    else if (self.front == 1)
    {
        next_top = self.top2;
        next_bottom = self.bottom2;
        next_face = self.face2;
        
        // change the top image
        self.front = 2;
    }
    else
    {
        next_top = self.top3;
        next_bottom = self.bottom3;
        next_face = self.face3;
        
        // change the top image
        self.front = 0;
    }
            
    NSString *currentId = [[PFUser currentUser] objectId];
    
    //_store = [KCSAppdataStore storeWithOptions:@{KCSStoreKeyCollectionName: @"Events", }];

    [KCSCustomEndpoints callEndpoint:@"getRandomProducts" params: nil completionBlock:^(id results, NSError *error) {
        if (results) {
            //NSLog(@"%@", results);
            NSLog(@"worked");
        } else {
            NSLog(@"error while downloading products from getRandomProducts %@", error);
        }
    }];
    
    /*
    // get random friend from the cloud
    ([PFCloud callFunctionInBackground:@"getRandomFriend"
                        withParameters:@{@"id": currentId}
                                 block:^(NSString *result, NSError *error) {
                                     if (!error) {
                                         // the result is a json encoded string
                                         //NSLog(@"Result in get rand friend is %@", result);
                                         next_face.profileID = result;
                                         //NSLog(@"Just finished profile");
                                         @synchronized(self) {
                                             // do the array shit here
                                             self.friendFacebookIds[((self.front - 1) % 3)] = result;
                                         }
                                         
                                     } else {
                                         NSLog(@"error while retrieving random friend");
                                     }
                                     @synchronized(self){
                                         self.profilePicDidLoad = YES;
                                     }
                                 }]);
    
    // get products from the cloud and load them
    [PFCloud callFunctionInBackground:@"getProducts"
                       withParameters:@{@"type": @"male_shoe"}
                                block:^(NSDictionary *result, NSError *error) {
                                    if (!error) {
                                        // the result is a json encoded string
                                        self.nextTopProductId = result[@"id_1"];
                                        self.nextBottomId = result[@"id_2"];
                                        next_top.file = result[@"img_1"];
                                        next_bottom.file = result[@"img_2"];
                                        // async load 
                                        [next_top loadInBackground];
                                        [next_bottom loadInBackground];
                                        @synchronized(self) {
                                            // do the array shit here 
                                            self.topProductIds[((self.front - 1) % 3)] = result[@"id_1"];
                                            self.bottomProductIds[((self.front - 1) % 3)] = result[@"id_2"];
                                            self.questionObjectIds[((self.front - 1) % 3)] = result[@"question_id"];
                                        }
                                    } else {
                                        NSLog(@"error while retrieving product");
                                    }
                                    @synchronized(self) {
                                        self.productsDidLoad = YES;
                                    }
                                }];
    */
}

-(void) createAnswerForCurrentProducts
{
    // create the answer and save to Parse in background
}

-(void) waitUntilLoad
{
    NSLog(@"Waiting");
    // add activity monitor animation
    
    // wait for 0.1 seconds and then recall refresh
    [self performSelector:@selector(refresh) withObject:self afterDelay:0.01];
}

// called everytime a new
- (void)refresh
{
    //NSLog(@"pro pic is:");
    //NSLog(self.profilePicDidLoad ? @"Yes" : @"No");
    //NSLog(@"products is:");
    //NSLog(self.productsDidLoad ? @"Yes" : @"No");
    
    // hide the appropriate variables
    if (self.profilePicDidLoad && self.productsDidLoad) {
        
        [self reloadIntoBackground];
        
        self.top.hidden = (self.front != 0);
        self.bottom.hidden = (self.front != 0);
        self.face.hidden = (self.front != 0);
        self.top2.hidden = (self.front != 1);
        self.bottom2.hidden = (self.front != 1);
        self.face2.hidden = (self.front != 1);
        self.top3.hidden = (self.front != 2);
        self.bottom3.hidden = (self.front != 2);
        self.face3.hidden = (self.front != 2);
        
        
        NSInteger greeting = arc4random() % 5;
        int intGreeting = greeting;
        [self.view addSubview: [[ToastAlert alloc] initWithText: thanks[intGreeting]]];
        
        //resets face position
        CGRect newButtonFrame = self.face.frame;
        newButtonFrame.origin.x = 120;
        newButtonFrame.origin.y = 260;
        self.face.frame = newButtonFrame;
        
        //resets checks
        self.leftCheck.alpha = 0;
        self.rightCheck.alpha = 0;
        
    } else {
        [self waitUntilLoad];
    }
    
}


- (IBAction)swipeRight:(id)sender {
    [self refresh];
}

- (IBAction)swipeLeft:(id)sender {
    [self refresh];
}

- (IBAction)touchLeft:(id)sender {
    [self refresh];
}

- (IBAction)touchRight:(id)sender {
    [self refresh];
}
@end

// need to figure out what the current object id's are 
