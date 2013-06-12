//
//  BackgroundRefreshOperation.m
//  Mockup
//
//  Created by Nithin Tumma on 6/10/13.
//  Copyright (c) 2013 Neel Patel. All rights reserved.
//

#import "BackgroundRefreshOperation.h"

@implementation BackgroundRefreshOperation

- (id)initWithDelegate: (id<BackgroundOperationDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
    }
    return self;
}


- (void) main{
    @autoreleasepool {
        if (self.isCancelled){
            return;
        }
        
        // start loading
        self.doneLoading = NO;
        
        // load facebook id from Parse
        
    }
}
@end
