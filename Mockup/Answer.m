//
//  Answerl.m
//  Mockup
//
//  Created by Nithin Tumma on 6/12/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "Answer.h"

@implementation Answer

// required for KCSPersistable protocol
-(NSDictionary *)hostToKinveyPropertyMapping {
    // maybe update to use dispatch_once to improve efficiency
    return @{
    @"entityId": KCSEntityKeyId,
    @"questionId": @"questionId",
    @"winningProductId": @"winningProductId",
    @"losingProductId": @"losingProductId",
    @"answerFromUserId": @"answerFromUserId",
    @"answerForFacebookId": @"answerForFacebookId",
    @"metadata": KCSEntityKeyMetadata
    };
    
}

@end

