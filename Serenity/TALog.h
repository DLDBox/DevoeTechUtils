//
//  TALog.h
//  ThinaireController
//
//  Created by Dana L Devoe on 6/1/15.
//  Copyright (c) 2015 Thinaire. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"%@@%d<%@>", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define DLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ELog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define WLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define MLog( s, ... ) [[NSNotificationCenter defaultCenter] postNotificationName:kWelcomeMessageDisplay object:nil userInfo:@{ @"notif_message" : s,@"duration" : @(5) }]
#else
#define DLog( s, ... )
#define ELog( s, ... )
#define WLog( s, ... )
#define MLog( s, ... )
#endif

//#define IAMHERE() DLog( @"%s",__PRETTY_FUNCTION__ )

