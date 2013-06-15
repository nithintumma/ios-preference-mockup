//
//  FeedObjectCell.h
//  Mockup
//
//  Created by Neel Patel on 6/14/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FeedObjectCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (weak, nonatomic) IBOutlet UIImageView *leftFriend;
@property (weak, nonatomic) IBOutlet UIImageView *rightFriend;

@property (weak, nonatomic) IBOutlet UITextView *question;
@property (weak, nonatomic) IBOutlet UITextView *date;
@property (weak, nonatomic) IBOutlet UITextView *leftCount;
@property (weak, nonatomic) IBOutlet UITextView *rightCount;



@end
