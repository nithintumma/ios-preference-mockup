//
//  ViewController.m
//  Mockup
//
//  Created by Neel Patel on 6/3/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    faces = [[NSArray alloc] initWithObjects:@"neel.jpg",@"nithin.jpg",@"james.jpg", nil];
    movies = [[NSArray alloc] initWithObjects:@"after_earth.jpg",@"fast6.jpg",@"internship.jpg", nil];
    music = [[NSArray alloc] initWithObjects:@"florida_georgia_line.jpg",@"macklemore.jpg",@"pink.jpg", @"timberlake.jpg", nil];
    shirts = [[NSArray alloc] initWithObjects:@"jcrew.jpg",@"polo.jpg",@"vneck.jpg", nil];
    shoes = [[NSArray alloc] initWithObjects:@"airforce.jpg",@"cole_haan.jpg",@"sperry.jpg", nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //to determine whose fase to show
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
            [self.left setImage:[UIImage imageNamed:movies[rand1]] forState:UIControlStateNormal];
            [self.right setImage:[UIImage imageNamed:movies[rand2]] forState:UIControlStateNormal];

            break;
        }
        //for music            
        case 1:            
        {
            int rand1 = getRand(4, -1);
            int rand2 = getRand(4, rand1);
            [self.left setImage:[UIImage imageNamed:music[rand1]] forState:UIControlStateNormal];
            [self.right setImage:[UIImage imageNamed:music[rand2]] forState:UIControlStateNormal];
            break;
        }
        //for shirts            
        case 2:           
        {
            int rand1 = getRand(3, -1);
            int rand2 = getRand(3, rand1);
            [self.left setImage:[UIImage imageNamed:shirts[rand1]] forState:UIControlStateNormal];
            [self.right setImage:[UIImage imageNamed:shirts[rand2]] forState:UIControlStateNormal];
            break;
        }
        //for shoes            
        default:
        {
            int rand1 = getRand(3, -1);
            int rand2 = getRand(3, rand1);
            [self.left setImage:[UIImage imageNamed:shoes[rand1]] forState:UIControlStateNormal];
            [self.right setImage:[UIImage imageNamed:shoes[rand2]] forState:UIControlStateNormal];
            break;
        }
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
