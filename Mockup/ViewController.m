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
#import "JSONKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [PFImageView class];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.face addGestureRecognizer:pangr];
    
    [super viewDidLoad];
    
    //initalizing all arrays
    thanks = [[NSArray alloc] initWithObjects:@"Thanks!",@"Good taste!",@"Haha, you're right!",@"Wow, you're good!",@"Crispy!", nil];
    faces = [[NSArray alloc] initWithObjects:@"neel.jpg",@"nithin.jpg",@"james.jpg", nil];
    movies = [[NSArray alloc] initWithObjects:@"after_earth.jpg",@"fast6.jpg",@"internship.jpg", nil];
    music = [[NSArray alloc] initWithObjects:@"florida_georgia_line.jpg",@"macklemore.jpg",@"pink.jpg", @"timberlake.jpg", nil];
    shirts = [[NSArray alloc] initWithObjects:@"jcrew.jpg",@"polo.jpg",@"vneck.jpg", nil];
    shoes = [[NSArray alloc] initWithObjects:@"airforce.jpg",@"cole_haan.jpg",@"sperry.jpg", nil];
    
    //starts it off for the first time
    [self refresh];
    
    
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

- (void)refresh
{
    // figure out how to do it in the cloud, that would be nice
    /*([PFCloud callFunctionInBackground:@"getProducts"
     withParameters:@{@"type": @"shirt"}
     block:^(NSString *result, NSError *error) {
     if (!error) {
     // the result is a json encoded string
     NSLog(@"%@", result);
     //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:result]; // error occurs here
     //NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
     //PFObject *response = [result dataUsingEncoding:NSUTF8StringEncoding];
     NSDictionary *json = [result objectFromJSONString];
     //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options: kNilOptions error: &error];
     NSLog(@"further");
     PFFile *img_1 = [json objectForKey: @"image"];
     } else {
     NSLog(@"error while retrieving product");
     }
     }];
     */
    
     // do the queries for now becuase the Cloud Code is not working
     PFQuery *query = [PFQuery queryWithClassName:@"Product"];
     [query whereKey: @"type" equalTo: [PFObject objectWithoutDataWithClassName:@"ProductType" objectId:@"NOXSpiVlla"]];
     [query findObjectsInBackgroundWithBlock: ^(NSArray *results, NSError *error) {
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
         
         NSInteger face = arc4random() % 3;
         int intFace = face;
         [self.face setImage:[UIImage imageNamed:faces[intFace]] forState:UIControlStateNormal];

         NSLog(@"Found products");
         
         // get the first object
         PFObject *p_1 = [results objectAtIndex: 0];
         self.top.file = [p_1 objectForKey:@"image"];
         
         PFObject *p_2 = [results objectAtIndex:1];
         self.bottom.file = [p_2 objectForKey:@"image"];
         [self.top loadInBackground];
         [self.bottom loadInBackground];

     }];
    /*
    //says thanks!
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
    
    //to determine whose face to show
    NSInteger face = arc4random() % 3;
    int intFace = face;
    [self.face setImage:[UIImage imageNamed:faces[intFace]] forState:UIControlStateNormal];
    
    //to determine what category (movies, music, shirts, shoes) to display
    NSInteger category = arc4random() % 4;
    int intCategory = category;
    
    switch (intCategory)
    {
            //for movies
        case 0:
        {
            int rand1 = getRand(3, -1);
            int rand2 = getRand(3, rand1);
            self.top.image = [UIImage imageNamed:movies[rand1]];
            self.bottom.image = [UIImage imageNamed:movies[rand2]];
            
            break;
        }
            //for music
        case 1:
        {
            int rand1 = getRand(4, -1);
            int rand2 = getRand(4, rand1);
            self.top.image = [UIImage imageNamed:music[rand1]];
            self.bottom.image = [UIImage imageNamed:music[rand2]];;
            break;
        }
            //for shirts
        case 2:
        {
            int rand1 = getRand(3, -1);
            int rand2 = getRand(3, rand1);
            self.top.image = [UIImage imageNamed:shirts[rand1]];
            self.bottom.image = [UIImage imageNamed:shirts[rand2]];
            break;
        }
            //for shoes
        default:
        {
            int rand1 = getRand(3, -1);
            int rand2 = getRand(3, rand1);
            self.top.image = [UIImage imageNamed:shoes[rand1]];
            self.bottom.image = [UIImage imageNamed:shoes[rand2]];
            break;
        }
    }
    
    
    */
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
