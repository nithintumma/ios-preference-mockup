//
//  ViewController.h
//  Mockup
//
//  Created by Neel Patel on 6/3/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    UIPanGestureRecognizer* gestureRecognizer;
    
    NSArray *thanks;
    NSArray *faces;
    NSArray *movies;
    NSArray *music;
    NSArray *shirts;
    NSArray *shoes;
}
@property (weak, nonatomic) IBOutlet UILabel *coord;

@property (weak, nonatomic) IBOutlet UIButton *face;
@property (weak, nonatomic) IBOutlet UIImageView *top;
@property (weak, nonatomic) IBOutlet UIImageView *bottom;

@property (weak, nonatomic) IBOutlet UIImageView *leftCheck;
@property (weak, nonatomic) IBOutlet UIImageView *rightCheck;
@property (weak, nonatomic) IBOutlet UILabel *question;

- (IBAction)swipeRight:(id)sender;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)touchLeft:(id)sender;
- (IBAction)touchRight:(id)sender;


@end
