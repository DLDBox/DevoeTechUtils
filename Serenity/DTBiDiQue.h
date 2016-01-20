//
//  DTBiDiQue.h
//  SmileTyme
//
//  Created by Dana Devoe on 5/29/15.
//  Copyright (c) 2015 Dana Devoe. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Dynamic/Static Bidirectional Queue
 */

@interface DTBiDiQue : NSObject

@property(assign) NSInteger maxQueDepth;

- (instancetype) initWithArray:(NSMutableArray *)objects;
- (void) addObjects:(NSArray *)objects;

#pragma mark - Head Methods
-(BOOL) pushHead:(id)anObject;
-(id) popHead;
-(id) peekHead;
-(BOOL) pokeHead:(id)anObject;
-(void) dropHead;

#pragma mark - Tail Methods
-(BOOL) pushTail:(id)anObject;
-(id) popTail;
-(id) peekTail;
-(BOOL) pokeTail:(id)anObject;
-(void) dropTail;

-(NSArray*) stack;
-(void) clear;
-(BOOL) isEmpty;
-(BOOL) isFull;
-(NSUInteger) depth;
-(void) removeObject:(id)anObject;

@end
