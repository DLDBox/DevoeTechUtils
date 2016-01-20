//
//  TAGlobals.h
//  TASampleApp
//
//  Created by Thinaire
//  Copyright (c) 2014 Thinaire. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// DebugLog helper
// In order to use this properly, you need to define DEBUG_MODE in the project settings for the debug build of the app only.
#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"%@@%d<%@>", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define DLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define IAMHERE() NSLog( @"%s@%d-mainthread(%@)",__PRETTY_FUNCTION__,__LINE__,[NSThread isMainThread] ? @"YES" : @"NO" )
#else
#define DLog( s, ... )
#define IAMHERE()
#endif

#define SEL2OBJ(s) [NSValue valueWithPointer:@selector(s)] // ...
#define OBJ2SEL(o) [o pointerValue] //usage: SEL selector = OBJ2SEL(obj);

//#define IAMHERE() DLog( @"%s",__PRETTY_FUNCTION__ )

#define DO_ONCE(b) {static dispatch_once_t onceToken_t; dispatch_once(&onceToken_t,b);}

#define WEAKSELF(x)  __weak typeof(self) x = self
#define BLOCKSELF(x) __weak typeof(self) weakSelf = self;__strong typeof(self) x = weakSelf

#define ERROR(s,n) [NSError errorWithDomain:s code:n userInfo:nil]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef NS_ENUM(NSUInteger, TApplicationOptions){
    TApplicationOptionNONE,
    TApplicationOptionURLSettings
};

