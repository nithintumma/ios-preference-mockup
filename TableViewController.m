//
//  TableViewController.m
//  Mockup
//
//  Created by Neel Patel on 6/13/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "TableViewController.h"
#import "Answer.h"
#import "FeedObject.h"
#import "FeedObjectCell.h"
#import <KinveyKit/KinveyKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h> 
#import "PaveAPIClient.h"


@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    //self.finishedGooglePlacesArray = [[NSArray alloc] init];
    
    //sets up the store for answers
    //self.store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"Answer",
               //KCSStoreKeyCollectionTemplateClass : [Answer class]}];
    //KCSCollection* collection = [KCSCollection collectionFromString:@"FeedObject" ofClass:[FeedObject class]];
    
    //sets up the store for answers
    //self.store = [KCSAppdataStore storeWithOptions:@{ KCSStoreKeyCollectionName : @"FeedObject",
    //           KCSStoreKeyCollectionTemplateClass : [FeedObject class]}];
    //self.store = [KCSAppdataStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:collection, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyNone], KCSStoreKeyCachePolicy, nil]];
    
    //self.paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //self.dataPath = [self.paths[0] stringByAppendingPathComponent:@"imageCache"];
    
    [self getFeedIds];
    
    [FBProfilePictureView class];

    self.tableView.allowsSelection=NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //loads image cache
    self.myImageCache = [SDImageCache.alloc initWithNamespace:@"FeedObjects"];
        
    [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, -500, 0))];    
    
    //rounds it
    self.tableView.layer.cornerRadius=5;
    
    [super viewDidLoad];    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.feedIds count];
}

- (void) getFeedIds
{
    NSLog(@"About to get feed ids");
    
    self.doneLoadingFeed = NO;
    KCSUser *activeUser = [KCSUser activeUser];
    NSString *currentId = [activeUser kinveyObjectId];
    
    
    //[KCSCustomEndpoints callEndpoint: @"getFeedIds" params: @{@"user_id":currentId} completionBlock:^(id results, NSError *error) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = @"/data/getallfeedobjects/";
    path = [path stringByAppendingString:[defaults objectForKey:@"profile"][@"facebookId"]];
    path = [path stringByAppendingString:@"/"];
    [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id results) {
        if (results) {
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            for(NSDictionary *current in results)
            {
                [ids addObject:current[@"id"]];
            }
            
            self.feedIds = ids;
            NSLog(@"Just finished getting feed ids: %@", self.feedIds);

            self.doneLoadingFeed = YES;
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        } }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error logging in user to Django %@", error);
        }];
     
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSLog(@"Called");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    KCSQuery* query = [KCSQuery query];
    KCSQuerySortModifier* sortByDate = [[KCSQuerySortModifier alloc] initWithField:@"Answer" inDirection:kKCSAscending];
    [query addSortModifier:sortByDate]; //sort the return by the date field
    [query setLimitModifer:[[KCSQueryLimitModifier alloc] initWithLimit:1]]; //just get back 10 results
    NSLog(@"about to get in self store: %@", query);
    [self.store queryWithQuery:query withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        NSLog(@"inside block: ");
        if (objectsOrNil) {
            NSLog(@"Objects array: ");
            NSLog(@"Objects array: %@", objectsOrNil[0]);
            //cell.textLabel.text = ((Answer*)objectsOrNil[0]).questionText;
            cell.textLabel.font=[UIFont systemFontOfSize:22.0];
            cell.textLabel.text = @"Hey";
            //UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 18.0 ];
            //cell.textLabel.font = myFont;
            
        }
    } withProgressBlock:nil];
    return cell;
    */
    
    NSLog(@"About to load stuff in");    
    FeedObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
    
    if(self.doneLoadingFeed)
    {
        cell.backgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"tablebackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"tablebackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
        NSLog(@"Ready to load!");         
        
        NSLog(@"Going to query for: %@", [self.feedIds objectAtIndex:indexPath.row]);
        
        /**
        KCSQuery* query = [KCSQuery queryOnField:@"userId" withExactMatchForValue: [self.feedIds objectAtIndex:indexPath.row]];

        KCSQuerySortModifier* sortByDate = [[KCSQuerySortModifier alloc] initWithField:@"FeedObject" inDirection:kKCSAscending];
        
        [query addSortModifier:sortByDate]; //sort the return by the date field
        
        [query setLimitModifer:[[KCSQueryLimitModifier alloc] initWithLimit:1]]; //just get back 1 result
        */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *path = [NSString stringWithFormat:@"/data/getfeedobject/%@/", [self.feedIds objectAtIndex:indexPath.row]];
        
        //path = [path stringByAppendingString:[self.feedIds objectAtIndex:indexPath.row]];

        [[PaveAPIClient sharedClient] postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id input) {
        //[self.store loadObjectWithID:[self.feedIds objectAtIndex:indexPath.row] withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            NSLog(@"inside block: query was %@", [self.feedIds objectAtIndex:indexPath.row]);
            if (input) {
                NSLog(@"Objects array: %@", input);
                
                NSDictionary *result = input[0];
                
                cell.question.text = result[@"fields"][@"questionText"];

                NSString* chosenFriend = result[@"fields"][@"fbFriend1"];
                NSString* wrongFriend = result[@"fields"][@"fbFriend2"];
                                                
                NSString *chosenName  = result[@"fields"][@"image1"];
                NSNumber *chosenNum  = result[@"fields"][@"product1Count"];
                NSString *wrongName  = result[@"fields"][@"image2"];
                NSNumber *wrongNum  = result[@"fields"][@"product2Count"];
                
                NSLog(@"Chosen name is first %@ with count %@", chosenName, chosenNum);
                if([chosenNum intValue] < [wrongNum intValue])
                {
                    NSLog(@"Switching");
                    chosenName  = result[@"fields"][@"image2"];
                    chosenNum  = result[@"fields"][@"product2Count"];
                    chosenFriend = result[@"fields"][@"fbFriend2"];

                    
                    wrongName  = result[@"fields"][@"image1"];
                    wrongNum  = result[@"fields"][@"product1Count"];
                    wrongFriend = result[@"fields"][@"fbFriend1"];
                }
                NSLog(@"Chosen name is now %@ with count %@", chosenName, chosenNum);
                
                //sets the labels
                cell.leftCount.text = [chosenNum stringValue];;
                cell.rightCount.text = [wrongNum stringValue];;
                
                NSString *leftURL = @"https://graph.facebook.com/";
                leftURL = [leftURL stringByAppendingString:chosenFriend];
                leftURL = [leftURL stringByAppendingString:@"/picture"];
                
                NSString *rightURL = @"https://graph.facebook.com/";                
                
                //if some people gave this response
                if([wrongNum intValue] != 0)
                {
                    NSLog(@"Wrong num is %@ %@", wrongNum, wrongFriend);
                    rightURL = [rightURL stringByAppendingString:wrongFriend];
                    rightURL = [rightURL stringByAppendingString:@"/picture"];
                }
                
                //gets the friends images
                [cell.leftFriend setImageWithURL:[NSURL URLWithString:leftURL]
                          placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                   options:SDWebImageRefreshCached];
                
                [cell.rightFriend setImageWithURL:[NSURL URLWithString:rightURL]
                                 placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                          options:SDWebImageRefreshCached];
                
                
                //gets the left image
                //[KCSResourceService saveLocalResource:[self.dataPath stringByAppendingPathComponent: chosenName] completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                //[KCSResourceService downloadResource:imgFilenameTop completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                //tries to download left image from cache
                [[SDImageCache sharedImageCache] queryDiskCacheForKey:chosenName done:^(UIImage *image, SDImageCacheType type)
                {
                    NSLog(@"Type %u", type);
                    NSLog(@"image %@", image);
                    if(image == nil)
                    {
                        //download normally
                    
                
                        [KCSResourceService downloadResource:chosenName completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                            if (errorOrNil == nil && objectsOrNil.count == 1) {
                                //successful download
                                KCSResourceResponse* response_left = objectsOrNil[0];
                                UIImage *currentImage = [UIImage imageWithData: response_left.resource];
                                [cell.leftImage
                                 setImage: currentImage];
                                NSLog(@"Got left image from server");
                                
                                //saves in cache
                                [[SDImageCache sharedImageCache] storeImage:currentImage forKey:chosenName toDisk:YES];

                                
                            } else {
                                NSLog(@"error downloading 'left image': %@",chosenName);
                            }
                        } progressBlock:nil];
                    }
                    else //if it found it in cache
                    {
                        [cell.leftImage
                         setImage: image];
                        NSLog(@"Got left image from cache");
                    }
                }];
                
                //gets the right image
                //[KCSResourceService saveLocalResource:[self.dataPath stringByAppendingPathComponent: wrongName] completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                [[SDImageCache sharedImageCache] queryDiskCacheForKey:wrongName  done:^(UIImage *image, SDImageCacheType type)
                 {
                     if(image == nil)
                     {
                         //download normally                         
                         [KCSResourceService downloadResource:wrongName completionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                             if (errorOrNil == nil && objectsOrNil.count == 1) {
                                 //successful download
                                 KCSResourceResponse* response_right = objectsOrNil[0];
                                 UIImage *currentImage = [UIImage imageWithData: response_right.resource];
                                 [cell.rightImage
                                  setImage: currentImage];
                                 NSLog(@"Got right image from server");
                                 
                                 //saves in cache
                                 [[SDImageCache sharedImageCache] storeImage:currentImage forKey:wrongName toDisk:YES];
                                 
                             } else {
                                 NSLog(@"error downloading 'right image': %@",chosenName);
                             }
                         } progressBlock:nil];
                     }
                     else //if it found it in cache
                     {
                         [cell.rightImage
                          setImage: image];
                         NSLog(@"Got right image from cache");
                     }
                 }];
                
                //rounds everything
                cell.rightFriend.layer.cornerRadius = 25;
                cell.rightFriend.clipsToBounds = YES;
                cell.leftFriend.layer.cornerRadius = 25;
                cell.leftFriend.clipsToBounds = YES;
                
                cell.rightImage.layer.cornerRadius = 25;
                cell.rightImage.clipsToBounds = YES;
                cell.leftImage.layer.cornerRadius = 25;
                cell.leftImage.clipsToBounds = YES;
                
            }}
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error logging in user to Django %@", error);
        }];


        return cell;
    }
    else
    {
        NSLog(@"No luck, waiting...");         
        //waits, then retries
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self tableView:tableView cellForRowAtIndexPath:indexPath];
        });
        
        return cell;
                        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
