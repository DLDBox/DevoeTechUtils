//
//  TAOperation.m
//  ThinaireController
//
//  Created by Dana L. DeVoe on 4/21/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "TAOperation.h"

@interface TAOperation()
{
@protected
    
    BOOL _isExecuting;
    BOOL _isFinished;
}

@end

@implementation TAOperation

#pragma mark - NSOperation Overrides
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (void)start
{
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self doWork];
}

- (void)doWork
{ // override this method
}

- (void)finish
{
    // generate the KVO necessary for the queue to remove him
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}

@end
