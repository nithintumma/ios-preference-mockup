//
//  TableViewController.h
//  Mockup
//
//  Created by Neel Patel on 6/13/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KinveyKit/KinveyKit.h>
#import "UIImageView+WebCache.h"

@interface TableViewController : UITableViewController <UITableViewDataSource>

// store the values of the required instance variables
@property (nonatomic, retain)KCSAppdataStore *store;
@property (nonatomic, retain)NSMutableArray *feedIds;
@property (nonatomic, strong)SDImageCache *myImageCache;
@property (nonatomic, assign)BOOL doneLoadingFeed;

//stores the image paths
@property (nonatomic, retain)NSArray *paths;
@property (nonatomic, retain)NSString *dataPath;

- (void)makeRestaurantRequests;
@end
