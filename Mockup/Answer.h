//
//  Answer.h
//  Mockup
//
//  Created by Nithin Tumma on 6/12/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Answer : NSObject <KCSPersistable>

@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *winningProductId;
@property (nonatomic, copy) NSString *losingProductId;
@property (nonatomic, copy) NSString *answerFromUserId;
@property (nonatomic, copy) NSString *answerForFacebookId;
@property (nonatomic, retain) KCSMetadata *metadata;

@end