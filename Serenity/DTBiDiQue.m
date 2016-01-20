//
//  DTBiDiQue.m
//  SmileTyme
//
//  Created by Dana Devoe on 5/29/15.
//  Copyright (c) 2015 Dana Devoe. All rights reserved.
//

#import "DTBiDiQue.h"

@interface DTBiDiQue()
@property (nonatomic,strong) NSMutableArray *queque;
@end

@implementation DTBiDiQue

- (id) init
{
    self = [super init];
    
    if (self) {
        self.queque = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype) initWithArray:(NSMutableArray *)objects
{
    if ( (self = [super init]) ) {
        self.queque = objects;
    }
    return self;
}

- (void) addObjects:(NSArray *)objects
{
    [self.queque addObjectsFromArray:objects];
}

-(BOOL) pushHead:(id)anObject
{
    [self.queque insertObject:anObject atIndex:0];
    
    if (self.maxQueDepth && self.maxQueDepth < self.queque.count ) {
        [self popTail];
    }
    return TRUE;
}

-(id) popHead
{
    id anObject = self.queque.firstObject;
    
    if ( anObject ) {
        [self.queque removeObjectAtIndex:0];
    }
    return anObject;
}

-(id) peekHead
{
    return self.queque.firstObject;
}

-(BOOL)pokeHead:(id)anObject
{
    [self dropHead];
    [self pushHead:anObject];
    return FALSE;
}

-(void) clear
{
    [self.queque removeAllObjects];
}

-(BOOL) isEmpty
{
    return self.queque.count == 0 ? TRUE : FALSE;
}

-(BOOL) isFull
{
    return self.maxQueDepth == 0 ? FALSE : self.queque.count >= self.maxQueDepth ;
}

-(NSUInteger) depth
{
    return self.queque.count;
}

-(void) dropHead
{
    [self.queque removeObjectAtIndex:0];
}

-(NSArray*) stack
{
    return self.queque;
}

-(void) removeObject:(id)anObject
{
    [self.queque removeObject:anObject];
}

-(BOOL) pushTail:(id)anObject
{
    [self.queque addObject:anObject];
    
    if (self.maxQueDepth && self.maxQueDepth < self.queque.count ) {
        [self popHead];
    }
    
    return FALSE;
}

-(id) popTail
{
    id anObject = self.queque.lastObject;
    
    [self.queque removeLastObject];
    return anObject;
}

-(id) peekTail
{
    id anObject = self.queque.lastObject;
    return anObject;
}

-(BOOL)pokeTail:(id)anObject
{
    [self dropTail];
    [self pushTail:anObject];
    return FALSE;
}

-(void) dropTail
{
    [self.queque removeLastObject];
}

@end
