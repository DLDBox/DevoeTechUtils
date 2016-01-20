//
//  TADurationTimers.h
//  ThinaireController
//
//  Created by AtWorkUser on 10/22/15.
//  Copyright © 2015 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TATimers.h"

/*This is a timer which will accept a list of start and stop NSDate and it handles overlaps only one
 timer active at a time
 */

@class TAID;
@interface TADurationTimers : NSObject

@property (nonatomic,copy) NSString *channelName; // the channel that this timer is used with

@property (nonatomic,copy) timerBlock globalStartBlock;
@property (nonatomic,copy) timerBlock globalEndBlock;

+ (instancetype)sharedInstance;

- (void) createTimerWithStartDate:(NSDate *)startDate
                      withEndDate:(NSDate *)endDate
                         withID:(TAID *)objID
                      withMessage:(NSString *)backgroundMessage
                   withStartBlock:(timerBlock)startBlock
                     withEndBlock:(timerBlock)endBlock;

- (void) run;
- (void) stop;
- (void) resetAll;

- (BOOL) test_runAllTest;

@end
