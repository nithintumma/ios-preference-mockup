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
#import <QuartzCore/QuartzCore.h> 

#import "AppDelegate.h"
#import "Answer.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize loginButton;
@synthesize question_label;

- (void)viewDidLoad
{
    NSLog(@"in ViewController");
    self.front = 0;
    [PFImageView class];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UIPanGestureRecognizer *pangr2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UIPanGestureRecognizer *pangr3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.face addGestureRecognizer:pangr];
    [self.face2 addGestureRecognizer:pangr2];
    [self.face3 addGestureRecognizer:pangr3];
        
    //hides all items besides the first set
    self.top.hidden = (self.front != 0);
    self.bottom.hidden = (self.front != 0);
    self.face.hidden = (self.front != 0);
    self.top2.hidden = (self.front != 1);
    self.bottom2.hidden = (self.front != 1);
    self.face2.hidden = (self.front != 1);
    self.top3.hidden = (self.front != 2);
    self.bottom3.hidden = (self.front != 2);
    self.face3.hidden = (self.front != 2);

    //initializes arrays
    self.friendFacebookIds = [[NSMutableArray alloc] initWithCapacity:3];
    self.topProductIds = [[NSMutableArray alloc] initWithCapacity:3];
    self.bottomProductIds = [[NSMutableArray alloc] initWithCapacity:3];
    self.topProductURLs = [[NSMutableArray alloc] initWithCapacity:3];
    self.bottomProductURLs = [[NSMutableArray alloc] initWithCapacity:3];
    self.questionIds = [[NSMutableArray alloc] initWithCapacity:3];
    self.questionTexts = [[NSMutableArray alloc] initWithCapacity:3];
    self.questionTypes = [[NSMutableArray alloc] initWithCapacity:3];
    [self.friendFacebookIds addObject:@"test"];
    [self.friendFacebookIds addObject:@"test"];
    [self.friendFacebookIds addObject:@"test"];
    [self.topProductIds addObject:@"test"];
    [self.topProductIds addObject:@"test"];
    [self.topProductIds addObject:@"test"];
    [self.topProductURLs addObject:@"test"];
    [self.topProductURLs addObject:@"test"];
    [self.topProductURLs addObject:@"test"];
    [self.bottomProductIds addObject:@"test"];
    [self.bottomProductIds addObject:@"test"];
    [self.bottomProductIds addObject:@"test"];
    [self.bottomProductURLs addObject:@"test"];
    [self.bottomProductURLs addObject:@"test"];
    [self.bottomProductURLs addObject:@"test"];
    [self.questionIds addObject:@"test"];
    [self.questionIds addObject:@"test"];
    [self.questionIds addObject:@"test"];
    [self.questionTexts addObject:@"test"];
    [self.questionTexts addObject:@"test"];
    [self.questionTexts addObject:@"test"];
    [self.questionTypes addObject:@"test"];
    [self.questionTypes addObject:@"test"];
    [self.questionTypes addObject:@"test"];
    
    NSLog(@"initialized all arrays: %@ %@ %@ %@", self.friendFacebookIds, self.topProductIds, self.bottomProductIds, self.questionTexts);
    
    //sets up the store for answers
    self.store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"Answer",
           KCSStoreKeyCollectionTemplateClass : [Answer class]}];
    
    //starts it off for the first time
    //[self reloadIntoBackgroundAtBeginning:0];
    [self reloadIntoBackgroundAtBeginning:1];
    [self reloadIntoBackgroundAtBeginning:2];
    [self reloadIntoBackground];

    //creates car movement constraint
    //Example of a constraint to position the Y axis of the text field.
    

    //[self refresh];
    
    [super viewDidLoad];
    
    [self.car setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = @{ @"car" : self.car };
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(170)-[car]" options:0 metrics:nil views:views]];
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//facebook stuff
- (void) handeLogin:(NSError*)errorOrNil
{
    if (errorOrNil != nil) {
         NSLog(@"FB shit didn't work :(((");
    } else {
        NSLog(@"FB shit worked!");
    }
    
}

- (IBAction)loginWithFacebook:(id)sender
{
    NSLog(@"In login w fb");
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = [delegate session];

    // if the session isn't open, let's open it now and present the login UX to the user
    if (!session.isOpen) {
        [session openWithCompletionHandler:^(FBSession *session,
                                             FBSessionState status,
                                             NSError *error) {
            if (status == FBSessionStateOpen) {
                NSString* accessToken = session.accessToken;
                [KCSUser loginWithWithSocialIdentity:KCSSocialIDFacebook accessDictionary:@{KCSUserAccessTokenKey : accessToken} withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                    [self handeLogin:errorOrNil];
                }];
            }
        }];
    }
    else
    {
        NSLog(@"Already in");
    }
}

//end of Facebook stuff

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
                
        UIView *draggedButton = recognizer.view;
        CGPoint translation = [recognizer translationInView:self.view];
        
        CGRect newButtonFrame = draggedButton.frame;
        //calculates a damping coefficient - the farther we are away from the center of the app, the more friction we will have (ranging from 0.5 to 1)        
        //assumes center at x=114,y=194 (wrong, but good enough for now)
        //x goes from -60 to 290, y goes from -40 to 430 (roughly, and once again wrong but good enough for now)
        //ranges roughly from 1 at the origin to 0.2 at the edge
        //NSLog(@"X coord: %f", newButtonFrame.origin.x);
        //NSLog(@"Y coord: %f", newButtonFrame.origin.y);
        
        float xdist = powf((1-(fabsf(114-newButtonFrame.origin.x)/180)*.3),2);
        float ydist = powf((1-(fabsf(194-newButtonFrame.origin.y)/250)*.3),2);
        
        //NSLog(@"X damp: %f", xdist);
        //NSLog(@"Y damp: %f", ydist);
        
        //newButtonFrame.origin.x += (translation.x*xdist);
        //newButtonFrame.origin.y += (translation.y*ydist);
        
        newButtonFrame.origin.x += (translation.x);
        newButtonFrame.origin.y += (translation.y);
                
        draggedButton.frame = newButtonFrame;
        
        //sets a slightly opaque checkmark over the right image
        
        //NSLog(@"X dist: %f", xdist);
        //NSLog(@"y dist: %f", ydist);
        
        
        //if we're on the top
        if(newButtonFrame.origin.y < 194)
        {
            self.leftCheck.alpha = 1.5 - ydist;
            self.rightCheck.alpha = 0;
        }
        else
        {
            self.leftCheck.alpha = 0;
            self.rightCheck.alpha = 1.5 - ydist;
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
        float dist = powf(194-newButtonFrame.origin.y,2);

        
        //NSLog(@"Distance: %f", dist);
        
        //if we're far away from the center, then keep same y and move to greater x side
        if(dist > 5000)
        {
            //if we're on top
            if(newButtonFrame.origin.y < 194)
            {
                draggedButton.hidden = true;
                NSLog(@"Saving top");
                [self saveCurrentAnswer:YES];
            }
            else
            {
                draggedButton.hidden = true;
                NSLog(@"Saving bottom");
                [self saveCurrentAnswer:NO];
            }
            draggedButton.frame = newButtonFrame;
          
        }
        else
        {
            //resets checks
            self.leftCheck.alpha = 0;
            self.rightCheck.alpha = 0;
            
            newButtonFrame.origin.x = 114;
            newButtonFrame.origin.y = 194;
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

-(void) moveCar
{
    //[self.view removeConstraint:self.carBehind];
    //[self.view removeConstraint:self.carSpace];
    
    //[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.question_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.car attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    //NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.car attribute:NSLayoutAttributeLeading relatedBy:0 toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:114];
    
    //[self.view addConstraints:@[con1]];
    if(self.car.frame.origin.x < 210)
    {
        [UIView animateWithDuration:0.4 animations:^{
            //self.car.layer.transform = CATransform3DMakeRotation(M_PI, 10.0, 10.0, 10.0);;
            //CGContextRef myContext = UIGraphicsGetCurrentContext();
            //CGContextTranslateCTM (myContext, 100, 50);


            //self.car.transform = CGAffineTransformMakeTranslation(self.car.frame.origin.x + 300,0);
            CGAffineTransform trans = CGAffineTransformTranslate(self.car.transform, 100,0);

            

         
            NSLog(@"Now at: %f", self.car.frame.origin.x);
            self.car.transform = trans;
            [self.view layoutIfNeeded];
        }];
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformIdentity;
        self.car.transform = trans;
        [self.view layoutIfNeeded];
    }

    
    
/**
    self.car.my.constant = 42.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }]
*/
    /**
    CGFloat originalY = self.car.layer.position.y;
    self.car.layer.position = CGPointMake(self.car.layer.position.x, 300.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = @(originalY);
    animation.toValue = @300.0;
    animation.duration = 1.0;
    [self.car.layer addAnimation:animation forKey:@"position"];
*/

    /**
    CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"position"];
    ba.duration = 0.3;
    ba.fromValue = [NSValue valueWithCGPoint:CGPointMake(25.0, 25.0)];
    //ba.toValue =
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)];
    ba.toValue = [NSValue valueWithCGPoint:CGPointMake(250.0, 100.0)];
    [self.car.layer addAnimation:ba forKey:nil];
    */
    
    //[UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];

    //self.car.frame.size.width = self.car.frame.size.width + 100;
    //UIView *car = self.car;
    //[car.layer setPosition:CGPointMake(100.0, 100.0)];
    //self.car.translatesAutoresizingMaskIntoConstraints=NO;
    //CGRect frame = car.layer.frame;
    //frame.size.width = 200;
    //frame.origin.y += 20;
    //self.car.layer.frame = frame;
    //[car.layer addAnimation:mover forKey:@"position"];
}


// gets a new friend and a new set of projects

//this actually loads in an image for TWO in the future
-(void) reloadIntoBackground
{
        
    // set indicators to false
    self.profilePicDidLoad = NO;
    self.productsDidLoad = NO;
    
    // init the current image holder
    PFImageView *next_top = self.top;
    PFImageView *next_bottom = self.bottom;
    FBProfilePictureView *next_face = self.face;
    
    //if we're currently at the last set
    if (self.front == 2){
        next_top = self.top2;
        next_bottom = self.bottom2;
        next_face = self.face2;
        
        // change the top image
        self.front = 0;
    }
    //otherwise if we're on the second set
    else if (self.front == 1)
    {
        next_top = self.top;
        next_bottom = self.bottom;
        next_face = self.face;
        
        // change the top image
        self.front = 2;
    }
    //otherwise if we're on the first set
    else
    {
        next_top = self.top3;
        next_bottom = self.bottom3;
        next_face = self.face3;
        
        // change the top image
        self.front = 1;
    }
    

    //NSString *currentId = [[PFUser currentUser] objectId];
    if ([KCSUser hasSavedCredentials]){
        NSLog(@"the user has saved credentials");
    }
    KCSUser *activeUser = [KCSUser activeUser];
    NSString *currentId = [activeUser kinveyObjectId];

    
    [KCSCustomEndpoints callEndpoint: @"getRandomFriend" params: nil completionBlock:^(id results, NSError *error) {
        if (results) {
            //NSLog(@"Result in get rand friend is %@", results);
            next_face.profileID = [NSString stringWithFormat:@"%@", results[@"facebook_id"]];
            
            //saves that facebook ID
            [self.friendFacebookIds replaceObjectAtIndex:((self.front+1)%3) withObject:[NSString stringWithFormat:@"%@", results[@"facebook_id"]]];
            
            //rounds
            next_face.layer.cornerRadius = CGRectGetWidth(next_face.bounds)/2;
            next_face.layer.masksToBounds = YES;
            NSLog(@"Just finished profile and count is %d", self.front);
        } else{
            NSLog(@"error loading random friend: %@", error);
        }
        self.profilePicDidLoad = YES;
    }];
    
    [KCSCustomEndpoints callEndpoint: @"getRandomProducts" params: nil completionBlock:^(id results, NSError *error) {
        if (results) {
            NSLog(@"%@", results);
            
            self.nextTopProductId = results[@"product_1"];
            self.nextBottomId = results[@"product_2"];
            
            //saves IDs of the top and bottom products
            
            [self.topProductIds replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"product_1"]];
            [self.bottomProductIds replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"product_2"]];
            
            //saves urls of top and bottom products
            [self.topProductURLs replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"img_1"]];
            [self.bottomProductURLs replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"img_2"]];
            
            //saves question info
            [self.questionIds replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"question_id"]];
            [self.questionTexts replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"question_text"]];
            [self.questionTypes replaceObjectAtIndex:((self.front+1)%3) withObject:results[@"type"]];

            NSLog(@"QUestions are %@", self.questionTexts);
            NSLog(@"Count is %d", self.front);
            //shows the current question
            self.question_label.text = [self.questionTexts objectAtIndex:(self.front+2)%3];
            
            NSString *imgFilenameTop = results[@"img_1"];
            NSString *imgFilenameBottom = results[@"img_2"];
            // load the images from the database
            // set the UIImageView's to the new values
            next_top.layer.cornerRadius = 10;
            next_top.layer.masksToBounds = YES;
            next_bottom.layer.cornerRadius = 10;
            next_bottom.layer.masksToBounds = YES;
            
            // download the top image
            [KCSResourceService downloadResource:imgFilenameTop completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                if (errorOrNil == nil && objectsOrNil.count == 1) {
                    //successful download
                    KCSResourceResponse* response = objectsOrNil[0];
                    [next_top setImage: [UIImage imageWithData: response.resource]];
                    NSLog(@"created top product image");
                } else {
                    NSLog(@"error downloading 'topProductImage'");
                }
            } progressBlock:nil];
            
            // download the top image
            [KCSResourceService downloadResource:imgFilenameBottom completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                if (errorOrNil == nil && objectsOrNil.count == 1) {
                    //successful download
                    KCSResourceResponse* response_bottom = objectsOrNil[0];
                    [next_bottom
                     setImage: [UIImage imageWithData: response_bottom.resource]];
                    NSLog(@"created bottom product image");
                    
                    
                } else {
                    NSLog(@"error downloading 'bottomProductImage'");
                }
            } progressBlock:nil];
            
        } else {
            NSLog(@"error retrieving random products: %@", error);
        }
        self.productsDidLoad = YES;
        
    }];    
}

//this actually loads in an image for TWO in the future
-(void) reloadIntoBackgroundAtBeginning:(NSInteger)current
{
    // set indicators to false
    self.profilePicDidLoad = NO;
    self.productsDidLoad = NO;
    
    // init the current image holder
    PFImageView *next_top = self.top;
    PFImageView *next_bottom = self.bottom;
    FBProfilePictureView *next_face = self.face;
    
    //if we're currently at the last set
    if (current == 2){
        next_top = self.top2;
        next_bottom = self.bottom2;
        next_face = self.face2;
        
        // change the top image
        //current = 0;
    }
    //otherwise if we're on the second set
    else if (current == 1)
    {
        next_top = self.top;
        next_bottom = self.bottom;
        next_face = self.face;
        
        // change the top image
        //current = 2;
    }
    //otherwise if we're on the first set
    else
    {
        next_top = self.top3;
        next_bottom = self.bottom3;
        next_face = self.face3;
        
        // change the top image
        //current = 1;
    }
    
    //NSString *currentId = [[PFUser currentUser] objectId];
    if ([KCSUser hasSavedCredentials]){
        NSLog(@"the user has saved credentials");
    }
    KCSUser *activeUser = [KCSUser activeUser];
    NSString *currentId = [activeUser kinveyObjectId];
    
    
    [KCSCustomEndpoints callEndpoint: @"getRandomFriend" params: nil completionBlock:^(id results, NSError *error) {
        if (results) {
            //NSLog(@"Result in get rand friend is %@", results);
            next_face.profileID = [NSString stringWithFormat:@"%@", results[@"facebook_id"]];
            
            //saves that facebook ID
            [self.friendFacebookIds replaceObjectAtIndex:((current+2)%3) withObject:[NSString stringWithFormat:@"%@", results[@"facebook_id"]]];
            
            //rounds
            next_face.layer.cornerRadius = CGRectGetWidth(next_face.bounds)/2;
            next_face.layer.masksToBounds = YES;
            NSLog(@"Just finished profile and count is %d", current);
            
        } else{
            NSLog(@"error loading random friend: %@", error);
        }
        self.profilePicDidLoad = YES;
    }];
    
    [KCSCustomEndpoints callEndpoint: @"getRandomProducts" params: nil completionBlock:^(id results, NSError *error) {
        if (results) {
            NSLog(@"%@", results);
            
            self.nextTopProductId = results[@"product_1"];
            self.nextBottomId = results[@"product_2"];
            
            //saves IDs of the top and bottom products
            
            [self.topProductIds replaceObjectAtIndex:((current+2)%3) withObject:results[@"product_1"]];
            [self.bottomProductIds replaceObjectAtIndex:((current+2)%3) withObject:results[@"product_2"]];
            
            //saves urls of top and bottom products
            [self.topProductURLs replaceObjectAtIndex:((current+2)%3) withObject:results[@"img_1"]];
            [self.bottomProductURLs replaceObjectAtIndex:((current+2)%3) withObject:results[@"img_2"]];
            
            //saves question info
            [self.questionIds replaceObjectAtIndex:((current+2)%3) withObject:results[@"question_id"]];
            [self.questionTexts replaceObjectAtIndex:((current+2)%3) withObject:results[@"question_text"]];
            [self.questionTypes replaceObjectAtIndex:((current+2)%3) withObject:results[@"type"]];
            
            NSLog(@"initialized all arrays: %@", self.questionTexts);
            
            NSString *imgFilenameTop = results[@"img_1"];
            NSString *imgFilenameBottom = results[@"img_2"];
            // load the images from the database
            // set the UIImageView's to the new values
            next_top.layer.cornerRadius = 10;
            next_top.layer.masksToBounds = YES;
            next_bottom.layer.cornerRadius = 10;
            next_bottom.layer.masksToBounds = YES;
            
            // download the top image
            [KCSResourceService downloadResource:imgFilenameTop completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                if (errorOrNil == nil && objectsOrNil.count == 1) {
                    //successful download
                    KCSResourceResponse* response = objectsOrNil[0];
                    [next_top setImage: [UIImage imageWithData: response.resource]];
                    NSLog(@"created top product image");
                } else {
                    NSLog(@"error downloading 'topProductImage'");
                }
            } progressBlock:nil];
            
            // download the top image
            [KCSResourceService downloadResource:imgFilenameBottom completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                if (errorOrNil == nil && objectsOrNil.count == 1) {
                    //successful download
                    KCSResourceResponse* response_bottom = objectsOrNil[0];
                    [next_bottom
                     setImage: [UIImage imageWithData: response_bottom.resource]];
                    NSLog(@"created bottom product image");
                    
                    
                } else {
                    NSLog(@"error downloading 'bottomProductImage'");
                }
            } progressBlock:nil];
            
        } else {
            NSLog(@"error retrieving random products: %@", error);
        }
        self.productsDidLoad = YES;
        
    }];
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
        
        //shows and hides the right ones
        self.top.hidden = (self.front != 0);
        self.bottom.hidden = (self.front != 0);
        self.face.hidden = (self.front != 0);
        self.top2.hidden = (self.front != 1);
        self.bottom2.hidden = (self.front != 1);
        self.face2.hidden = (self.front != 1);
        self.top3.hidden = (self.front != 2);
        self.bottom3.hidden = (self.front != 2);
        self.face3.hidden = (self.front != 2);
        
        //prints the values for the current items
        NSLog(@"Current fb array: %@", self.friendFacebookIds);
        NSLog(@"Current fb id: %@", [self.friendFacebookIds objectAtIndex:self.front]);
        NSLog(@"Current top id: %@", [self.topProductIds objectAtIndex:self.front]);
        NSLog(@"Current bottom id: %@", [self.bottomProductIds objectAtIndex:self.front]);
        
        [self reloadIntoBackground];
        
        NSInteger greeting = arc4random() % 5;
        int intGreeting = greeting;
        [self.view addSubview: [[ToastAlert alloc] initWithText: thanks[intGreeting]]];
        
        //resets face position
        CGRect newButtonFrame = self.face.frame;
        newButtonFrame.origin.x = 108;
        newButtonFrame.origin.y = 237;
        self.face.frame = newButtonFrame;

        //resets checks
        self.leftCheck.alpha = 0;
        self.rightCheck.alpha = 0;
        
    } else {
        [self waitUntilLoad];
    }
    
}

-(void) saveCurrentAnswer:(bool)top {
    //moves car
    [self moveCar];
    
    NSLog(@"initialized all arrays: %@ %@ %@ %@", self.friendFacebookIds, self.topProductIds, self.bottomProductIds, self.questionTexts);
    NSLog(@"Front: %d", (self.front+2)%3);
    
    
    //creates answer
    Answer* dbAnswer = [[Answer alloc] init];
    dbAnswer.questionId = [self.questionIds objectAtIndex:(self.front+2)%3];
    dbAnswer.questionText = [self.questionTexts objectAtIndex:(self.front+2)%3];
    dbAnswer.productType = [self.questionTypes objectAtIndex:(self.front+2)%3];
    
    dbAnswer.answerFromUserId = [KCSUser activeUser].userId;
    //dbAnswer.answerForFacebookId =  [self.friendFacebookIds objectAtIndex:(self.front+2)%3];
    dbAnswer.answerForFacebookId =  @"1256912018";
    dbAnswer.answerFromFacebookId = [[[KCSUser activeUser] getValueForAttribute:@"profile"] objectForKey:@"facebookId"];
    
        
    //if they selected the top one
    if(top)
    {
        dbAnswer.winningProductId = [self.topProductIds objectAtIndex:(self.front+2)%3];
        dbAnswer.losingProductId = [self.bottomProductIds objectAtIndex:(self.front+2)%3];
        
        dbAnswer.winningProductFileName = [self.topProductURLs objectAtIndex:(self.front+2)%3];
        dbAnswer.losingProductFileName = [self.bottomProductURLs objectAtIndex:(self.front+2)%3];        
        
    }
    else
    {
        dbAnswer.winningProductId = [self.bottomProductIds objectAtIndex:(self.front+2)%3];
        dbAnswer.losingProductId = [self.topProductIds objectAtIndex:(self.front+2)%3];
        
        dbAnswer.winningProductFileName = [self.bottomProductURLs objectAtIndex:(self.front+2)%3];
        dbAnswer.losingProductFileName = [self.topProductURLs objectAtIndex:(self.front+2)%3];
    }

    [self.store saveObject:dbAnswer withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil != nil) {
            //save failed, show an error alert
            NSLog(@"Saving failed :( %@, %@", [errorOrNil localizedFailureReason], dbAnswer);
        } else {
            //save was successful
            NSLog(@"Successfully saved event (id='%@').", [objectsOrNil[0] kinveyObjectId]);
        }
    } withProgressBlock:nil];
    
    [self refresh];  
    
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
