//
//  BackgroundRefreshOperation.h
//  Mockup
//
//  Created by Nithin Tumma on 6/10/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@protocol BackgroundOperationDelegate;

@interface BackgroundRefreshOperation : NSOperation

@property (nonatomic, assign) id <BackgroundOperationDelegate> delegate;

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

- (id)initWithDelegate:(id<BackgroundOperationDelegate>) theDelegate;

@end

@protocol BackgroundOperationDelegate <NSObject>

- (void)backgroundProcessDidFinish:(BackgroundRefreshOperation *)downloader;
@end
