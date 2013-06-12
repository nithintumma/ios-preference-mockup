//
//  ViewController.h
//  Mockup
//
//  Created by Neel Patel on 6/3/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//  as part of Mockup project

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

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

@property (weak, nonatomic) IBOutlet FBProfilePictureView *face;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *face2;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *face3;
@property (weak, nonatomic) IBOutlet PFImageView *top;
@property (weak, nonatomic) IBOutlet PFImageView *bottom;
@property (weak, nonatomic) IBOutlet PFImageView *top2;
@property (weak, nonatomic) IBOutlet PFImageView *bottom2;
@property (weak, nonatomic) IBOutlet PFImageView *top3;
@property (weak, nonatomic) IBOutlet PFImageView *bottom3;

// store the values of the required instance variables 
@property (weak, nonatomic) NSMutableArray *topProductIds;
@property (weak, nonatomic) NSMutableArray *bottomProductIds;
@property (weak, nonatomic) NSMutableArray *friendFacebookIds;
@property (weak, nonatomic) NSMutableArray *questionObjectIds;

@property (weak, nonatomic) NSString *currentTopProductId;
@property (weak, nonatomic) NSString *currentBottomProductId;

// keeps track of which PFImageView is Hidden
@property (nonatomic, assign) NSInteger front;

// properties to hold the next product and friend
@property (weak, nonatomic) PFFile *nextTopImage;
@property (weak, nonatomic) PFFile *nextBottomImage;
@property (weak, nonatomic) NSString *nextTopProductId;
@property (weak, nonatomic) NSString *nextBottomId;
@property (weak, nonatomic) NSString *nextFriendFacebokId;
@property (weak, nonatomic) NSString *nextFriendName;
@property (weak, nonatomic) NSString *nextFriendGender;

// set to YES when background job completes needs to be locked
@property (nonatomic, assign) BOOL doneLoading;
@property (nonatomic, assign) BOOL profilePicDidLoad;
@property (nonatomic, assign) BOOL productsDidLoad;


@property (weak, nonatomic) IBOutlet UIImageView *leftCheck;
@property (weak, nonatomic) IBOutlet UIImageView *rightCheck;
@property (weak, nonatomic) IBOutlet UILabel *question;

- (IBAction)swipeRight:(id)sender;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)touchLeft:(id)sender;
- (IBAction)touchRight:(id)sender;


@end
