//
//  TADate.h
//  ios-new-debug
//
//  Created by Dana L. DeVoe on 6/1/15.
//  Copyright (c) 2015 Thinaire. All rights reserved.
//

#import <Foundation/Foundation.h>

//Date to string formats
static NSString *const D2S_FORMAT_DATETIME = @"yyyy-MM-dd'@'HH:mm";
static NSString *const D2S_FORMAT_DATE = @"yyyy-MM-dd";
static NSString *const D2S_FORMAT_TIME = @"HH:mm";

//String to Date formats
static NSString *const S2D_FORMAT_DATETIME = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
static NSString *const S2D_FORMAT_DATE = @"yyyy-MM-dd";
static NSString *const S2D_FORMAT_TIME = @"HH:mm:ss";


NSDate *stringToDate(NSString *dataString);
NSString *dateToISOFormat(NSDate *date);