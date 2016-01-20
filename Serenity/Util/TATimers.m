//
//  TATimers.m
//  ThinaireController
//
//  Created by Dana Devoe on 9/10/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "TATimers.h"
#import "TAGlobals.h"

@interface TATimers()

@property (nonatomic,strong) NSTimer *theRepeatTimer;

@property (nonatomic,strong) NSMutableDictionary *activeRepeatTimers;
@property (nonatomic,strong) NSMutableDictionary *suspendedRepeatTimers;
@property (nonatomic,strong) NSArray *sortedTimers;

@end

NSString *const kTimerKeyTimeout = @"kTimerKeyTimeout";
NSString *const kTimerKeyBlock = @"kTimerKeyBlock";
NSString *const kTimerKeyTimerDate = @"kTimerKeyTimerValue";
NSString *const kTimerKeyUserData = @"kTimerKeyUserData";

@implementation TATimers

+ (instancetype) sharedInstance
{
    static TATimers *sharedInstance;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate,^(){
        sharedInstance = [[TATimers alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    
    if ( self )
    {
        _activeRepeatTimers = [[NSMutableDictionary alloc] init];
        _suspendedRepeatTimers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL) createRepeatTimerWithKey:(id)key withTimeout:(NSTimeInterval)timeout withData:(id)userData withBlock:(timerBlock)block
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [_activeRepeatTimers setObject:[@{ kTimerKeyTimerDate : [NSDate date]
                                     , kTimerKeyTimeout : @(timeout)
                                     , kTimerKeyBlock : block
                                     , kTimerKeyUserData : userData ?: [NSNull null] } mutableCopy] forKey:key];
        
        if ( _theRepeatTimer == nil ) {
            _theRepeatTimer = [self startARepeatTimerWithDuration:[self smallestTimeoutValue] withSelector:@selector(internalTimerMethod:)];
        }
        else{
            [self resetTimerTimeoutIfNeeded:timeout];
        }
    });
    
//    @synchronized(self){
//        
//    }
    return TRUE;
}

- (void) resetTimerTimeoutIfNeeded:(NSTimeInterval)timeout
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        if ( timeout < _theRepeatTimer.timeInterval )
        {
            [_theRepeatTimer invalidate];
            _theRepeatTimer = nil;
            
            _theRepeatTimer = [self startARepeatTimerWithDuration:timeout withSelector:@selector(internalTimerMethod:)];
        }
    });
}

- (void) killRepeatTimerWithKey:(id)key
{
    @synchronized(self){
        [_activeRepeatTimers removeObjectForKey:key];
        [_suspendedRepeatTimers removeObjectForKey:key];
        
        if ( _activeRepeatTimers.count == 0 ) {
            [self killGlobalTimer];
        }
    }
}

- (void) suspendRepeatTimerWithKey:(id)key
{
    @synchronized(self){
        NSMutableDictionary *timerInfo = _activeRepeatTimers[key];
        
        if ( timerInfo )
        {
            [_suspendedRepeatTimers setObject:timerInfo forKey:key];
            
            if ( _activeRepeatTimers.count == 0 ) {
                [self killGlobalTimer];
            }
        }
        
    }
}

- (void) resumeRepeatTimerWithKey:(id)key
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSMutableDictionary *timerInfo = _suspendedRepeatTimers[key];
        
        if ( timerInfo )
        {
            [_activeRepeatTimers setObject:timerInfo forKey:key];
            
            if ( _theRepeatTimer == nil ) {
                _theRepeatTimer = [self startARepeatTimerWithDuration:[self smallestTimeoutValue] withSelector:@selector(internalTimerMethod:)];
            }
            else{
                NSTimeInterval timeout = [timerInfo[kTimerKeyTimeout] doubleValue];
                [self resetTimerTimeoutIfNeeded:timeout];
            }
        }
    });
    
//    @synchronized(self){
//    }
}

- (void) killAllRepeatTimers
{
    @synchronized(self){
        [_activeRepeatTimers removeAllObjects];
        
        [_theRepeatTimer invalidate];
        _theRepeatTimer = nil;
    }
}

- (void) suspendAllRepeatTimers
{
    @synchronized(self){
        [_suspendedRepeatTimers addEntriesFromDictionary:_activeRepeatTimers];
        [_activeRepeatTimers removeAllObjects];
        
        [self killGlobalTimer];
    }
}

#pragma mark helper methods
- (NSTimeInterval) smallestTimeoutValue
{
    NSArray *keys = [_activeRepeatTimers allKeys];
    NSTimeInterval smallInterval = 60;
    
    for ( id aKey in keys )
    {
        NSMutableDictionary *muDict = _activeRepeatTimers[aKey];
        
        NSTimeInterval timeOut = [muDict[kTimerKeyTimeout] doubleValue];
        
        if ( timeOut < smallInterval ) {
            smallInterval = timeOut;
        }
    }
    
    return smallInterval;
}

- (void) internalTimerMethod:(id)userData
{ // now process each timer entery to determine if it has expired
    NSArray *keys = [_activeRepeatTimers allKeys];
    
    for ( id aKey in keys )
    {
        NSMutableDictionary *muDict = _activeRepeatTimers[aKey];
        
        NSTimeInterval timeOut = [muDict[kTimerKeyTimeout] doubleValue];
        NSDate *startDate = muDict[kTimerKeyTimerDate];
        NSDate *now = [NSDate date];
        
        if ( [now timeIntervalSinceNow] - [startDate timeIntervalSinceNow] > timeOut )
        { //update the timer value
            muDict[kTimerKeyTimerDate] = now;
            timerBlock aTimerBlock = muDict[kTimerKeyBlock];
            
            //DLog( @"Firing timer(%@)",aKey ) ;
            
            aTimerBlock( muDict[kTimerKeyUserData] ) ;
        }
    }
}

- (NSTimer *) startARepeatTimerWithDuration:(NSTimeInterval)duration withSelector:(SEL)selector
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:duration];
    
    NSTimer *aTimer = [[NSTimer alloc] initWithFireDate:futureDate
                                               interval:duration
                                                 target:self
                                               selector:selector
                                               userInfo:nil
                                                repeats:YES];
    [runLoop addTimer:aTimer forMode:NSDefaultRunLoopMode];
    
    return aTimer;
}

- (void) killGlobalTimer
{
    [_theRepeatTimer invalidate];
    _theRepeatTimer = nil;
}

- (NSTimeInterval) timeIntervalForKey:(id)key
{
    NSTimeInterval returnValue = 0;
    NSMutableDictionary *timerInfo = _activeRepeatTimers[key] ?: _suspendedRepeatTimers[key];
    
    if ( timerInfo ) {
        returnValue = [timerInfo[kTimerKeyTimeout] doubleValue];
    }

    return returnValue;
}

@end
