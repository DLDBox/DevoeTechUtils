//
//  TADurationTimers.m
//  ThinaireController
//
//  Created by AtWorkUser on 10/22/15.
//  Copyright © 2015 Google. All rights reserved.
//

#import "TADurationTimers.h"
#import "DTBiDiQue.h"
//#import "TAID.h"

#define TAID NSString

@interface TADuration : NSObject

@property (nonatomic,assign) NSInteger durationID;
@property (nonatomic,assign) BOOL isEndDate;  // FALSE if this the start date

@property (nonatomic,strong) NSDate *date; // the startDate/endDate
@property (nonatomic,strong) NSString *idObj; // the idObject with the startdate and enddate
@property (nonatomic,strong) NSString *backgroundMessage; // The message to use with the UILocalNotification
@property (nonatomic,copy) timerBlock block;

- (NSComparisonResult)compare:(TADuration *)otherObject;

@end

@implementation TADuration

- (NSComparisonResult)compare:(TADuration *)otherObject {
    return [otherObject.date compare:self.date];
}

@end


@interface TADurationTimers()

@property (nonatomic,strong) DTBiDiQue *que;
@property (nonatomic,strong) NSTimer *currentTimer;
@property (nonatomic,strong) TADuration *currentDuration;

@property (nonatomic,strong) NSMutableArray *localNotifications;

@property (nonatomic,assign) NSNumber *endTimer; // indicates if currentTimer is an end timer

@end

@implementation TADurationTimers

+ (instancetype) sharedInstance
{
    static TADurationTimers *sharedInstance;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^(){
        sharedInstance = [[TADurationTimers alloc] init];
    });
    
    return sharedInstance;
}


- (DTBiDiQue *)que
{
    if ( _que == nil ) {
        _que = [[DTBiDiQue alloc] init];
    }
    return _que;
}

- (NSMutableArray *)localNotificationIndexes
{
    if ( _localNotifications == nil ) {
        _localNotifications = [[NSMutableArray alloc] init];
    }
    
    return _localNotifications;
}

- (void) createTimerWithStartDate:(NSDate *)startDate
                      withEndDate:(NSDate *)endDate
                           withID:(NSString *)idObj
                      withMessage:(NSString *)backgroundMessage
                   withStartBlock:(timerBlock)startBlock
                     withEndBlock:(timerBlock)endBlock;
{
    TADuration *start = [[TADuration alloc] init];
    TADuration *end = [[TADuration alloc] init];
    
    if ( [startDate compare:endDate] == NSOrderedDescending ) {
        timerBlock swap = startBlock;
        startBlock = endBlock;
        endBlock = swap;
        
        NSDate *swapDate = startDate;
        startDate = endDate;
        endDate = swapDate;
    }
    
    // if the start date is in the past, then exit
//    if ( !startDate || !endDate || [startDate compare:[NSDate date]] == NSOrderedAscending ) {
//        WLog( @"The start date is in the past (%@)",startDate );
//        return ;
//    }
    
    start.durationID = [self.que depth];
    start.isEndDate = FALSE;
    start.date = startDate;
    start.idObj = idObj;
    start.block = startBlock;
    start.backgroundMessage = backgroundMessage;
    
    end.durationID = start.durationID;
    end.isEndDate = TRUE;
    end.date = endDate;
    end.idObj = idObj;
    end.block = endBlock;
    end.backgroundMessage = backgroundMessage;
    
    [self.que pushHead:start];
    [self.que pushHead:end];
}

- (void) run
{ // ...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    // Ask to be notified when the app comes back from the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [self sortQue];
    DLog( @"Starting Lisnr now (%@)",[NSDate date] );
    
    TADuration *duration = [self.que popTail];
    NSAssert( duration.isEndDate == FALSE, @"Time Sorting error" );
    
    self.endTimer = @(FALSE);
    self.currentDuration = duration;
    self.currentTimer = [self startAtimerWithDate:duration.date withUserBlock:duration.block withSelector:@selector(startDateMethod:)];
}

- (void) stop
{
    [self resetAll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // cancel any UILocalNotifications pending
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // cancel only the UILocalNotification that I created
    for ( UILocalNotification *aLocalNotification in self.localNotifications ) {
        [[UIApplication sharedApplication] cancelLocalNotification:aLocalNotification];
    }
    [self.localNotifications removeAllObjects];
}

- (void) resetAll
{
    if ( self.currentTimer ) {
        [self.currentTimer invalidate];
        self.currentTimer = nil;
    }
    [self.que clear];
}


- (NSTimer *) startAtimerWithDate:(NSDate *)date withUserBlock:(timerBlock)block withSelector:(SEL)selector
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    NSTimer *aTimer = [[NSTimer alloc] initWithFireDate:date
                                               interval:0.0
                                                 target:self
                                               selector:selector
                                               userInfo:block
                                                repeats:NO];
    
    [runLoop addTimer:aTimer forMode:NSDefaultRunLoopMode];
    
    return aTimer;
}

- (void) sortQue
{
    NSMutableArray *sortedArray = [[[self.que stack] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    
    _que = [[DTBiDiQue alloc] initWithArray:sortedArray];
}

- (void) startDateMethod:(NSTimer *)theTimer
{
    TADuration *duration = [self.que popTail];  // get the end date
    timerBlock block = theTimer.userInfo;
    
    NSAssert( duration , @"Time Sorting error" );
    
    if ( duration.isEndDate == FALSE ) // I have another start date, so drop it and the next endDate
    {
        duration = [self.que popTail];
        duration = [self.que popTail]; // now I have the correct endDate
        
        NSAssert( duration.isEndDate == TRUE, @"Time Sorting error" );
    }
    
    if ( !block && self.globalStartBlock) {
        self.globalStartBlock(nil);
    }
    else if( block ){
        block(nil);
    }
    
    [theTimer invalidate];
    self.endTimer = @(TRUE);
    self.currentDuration = duration;
    self.currentTimer = [self startAtimerWithDate:duration.date withUserBlock:duration.block withSelector:@selector(endDateMethod:)];
}

- (void) endDateMethod:(NSTimer *)theTimer
{
    TADuration *duration = [self.que popTail];
    timerBlock block = theTimer.userInfo;
    
    if ( !block && self.globalEndBlock) {// IF there is not local block, and there is a globalblock call it
        self.globalEndBlock(nil);
    }
    else if( block ){ // if a block is defined called it
        block(nil);
    }
    
    if ( duration == nil ) { // I am done
        return ;
    }
    
    NSAssert( duration.isEndDate == FALSE, @"Time Sorting error" );
    
    [theTimer invalidate];
    self.endTimer = @(FALSE);
    self.currentDuration = duration;
    self.currentTimer = [self startAtimerWithDate:duration.date withUserBlock:duration.block withSelector:@selector(startDateMethod:)];
}

#pragma mark - NSNotification Methods
- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    DLog( @"======================= Lisnr Entered Background =======================" );
    // create UILocalNotification to handle Lisnr start time
    
    //if ( que.depth && (self.endTimer != nil) && self.endTimer.boolValue == FALSE )
    // if the timer has already expired, then it was handled while the app was in the foreground
    if ( self.currentTimer.fireDate > [NSDate date] )
    {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        localNotif.alertBody = self.currentDuration.backgroundMessage;
        
#ifdef DEBUG
        if ( localNotif.alertBody == nil ) {
            localNotif.alertBody = @"DebugMode: Missing Lisnr Message.";
        }
#else
        if ( localNotif.alertBody == nil ) {
            return ;
        }
#endif
        
        localNotif.applicationIconBadgeNumber = [UIApplication sharedApplication].scheduledLocalNotifications.count;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.userInfo = @{ @"lisnr" : @(TRUE)
                               , @"channel_name" : self.channelName
                               , @"type" : @(self.currentDuration.idObj.type)
                               , @"start_date" : self.currentDuration.idObj.lisnrStartDate
                               , @"end_date" : self.currentDuration.idObj.lisnrStopDate
                               }; // on the app launch this means start the Lisnr
        
#ifdef USE_TEMPORARY_DATE
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:START_OFFSET];
#else
        localNotif.fireDate = self.currentTimer.fireDate;
#endif
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [self.localNotifications addObject:localNotif];
    }
}

- (void) applicationWillEnterForeground:(NSNotification *)notification
{
    DLog( @"======================= Lisnr Entered Foreground =======================" );
    
    NSDictionary *dictionary = notification.userInfo;
    
    if ( dictionary[@"lisnr"] ) {  // make sure it is our dictionary
        DLog( @"que has %lul items\nStarting Lisnr",(unsigned long)[self.que depth] );
    }
}

#pragma mark - Test Methods
- (BOOL) test_runAllTest
{
    BOOL returnResult = [self test_Basic];
    //returnResult &= [self test_Routine];
    //returnResult &= [self test_Advanced];
    
    return returnResult;
}

- (BOOL) test_Basic
{
    TADurationTimers *timer = [TADurationTimers sharedInstance];
    
    NSDate *in30Sec = [NSDate dateWithTimeIntervalSinceNow:30];
    NSDate *in120Sec = [NSDate dateWithTimeIntervalSinceNow:60];
    
    [timer createTimerWithStartDate:in30Sec withEndDate:in120Sec
                             withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                           
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                               [self test_Routine];
                           });
                       }];
    
    [timer run];
    
    return TRUE;
}

- (BOOL) test_Routine
{
    TADurationTimers *timer = [TADurationTimers sharedInstance];
    
    NSDate *in10Sec = [NSDate dateWithTimeIntervalSinceNow:10];
    NSDate *in30Sec = [NSDate dateWithTimeIntervalSinceNow:30];
    
    [timer createTimerWithStartDate:in10Sec withEndDate:in30Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in40Sec = [NSDate dateWithTimeIntervalSinceNow:40];
    NSDate *in60Sec = [NSDate dateWithTimeIntervalSinceNow:60];
    
    [timer createTimerWithStartDate:in40Sec withEndDate:in60Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in80Sec = [NSDate dateWithTimeIntervalSinceNow:80];
    NSDate *in100Sec = [NSDate dateWithTimeIntervalSinceNow:100];
    
    [timer createTimerWithStartDate:in80Sec withEndDate:in100Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                           
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                               [self test_Advanced];
                           });
                       }];
    
    
    [timer run];
    
    return TRUE;
}

- (BOOL) test_Advanced
{
    TADurationTimers *timer = [TADurationTimers sharedInstance];
    
    NSDate *in10Sec = [NSDate dateWithTimeIntervalSinceNow:10];
    NSDate *in30Sec = [NSDate dateWithTimeIntervalSinceNow:30];
    
    [timer createTimerWithStartDate:in10Sec withEndDate:in30Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in15Sec = [NSDate dateWithTimeIntervalSinceNow:15];
    NSDate *in40Sec = [NSDate dateWithTimeIntervalSinceNow:40];
    
    [timer createTimerWithStartDate:in15Sec withEndDate:in40Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in50Sec = [NSDate dateWithTimeIntervalSinceNow:50];
    NSDate *in70Sec = [NSDate dateWithTimeIntervalSinceNow:70];
    
    [timer createTimerWithStartDate:in50Sec withEndDate:in70Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in90Sec = [NSDate dateWithTimeIntervalSinceNow:90];
    NSDate *in95Sec = [NSDate dateWithTimeIntervalSinceNow:95];
    
    [timer createTimerWithStartDate:in90Sec withEndDate:in95Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                       }];
    
    NSDate *in80Sec = [NSDate dateWithTimeIntervalSinceNow:80];
    NSDate *in110Sec = [NSDate dateWithTimeIntervalSinceNow:110];
    
    [timer createTimerWithStartDate:in80Sec withEndDate:in110Sec
                           withID:nil
                        withMessage:@"Background Message"
                     withStartBlock:^(id userData){
                         DLog( @"Start block called" );
                     }
                       withEndBlock:^(id userData){
                           DLog( @"End block called" );
                           
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                               [self test_Advanced];
                           });
                       }];
    
    
    [timer run];
    
    return TRUE;
}



@end
