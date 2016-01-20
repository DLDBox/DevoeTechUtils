//
//  TATimers.h
//  ThinaireController
//
//  Created by Dana Devoe on 9/10/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

/* This is a generic time object.  Any number of timers can be created.  A block is called
 each time a timer fires
 */

typedef void (^timerBlock)(id userData);

@interface TATimers : NSObject

+ (instancetype) sharedInstance;

- (BOOL) createRepeatTimerWithKey:(id)key withTimeout:(NSTimeInterval)timeout withData:(id)userData withBlock:(timerBlock)block;
- (void) killRepeatTimerWithKey:(id)key;
- (void) killAllRepeatTimers;

- (void) suspendRepeatTimerWithKey:(id)key;
- (void) resumeRepeatTimerWithKey:(id)key;
- (void) suspendAllRepeatTimers;

- (NSTimeInterval) timeIntervalForKey:(id)key;

@end
