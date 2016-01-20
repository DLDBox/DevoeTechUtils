//
//  TADate.m
//  ios-new-debug
//
//  Created by Dana L. DeVoe on 6/1/15.
//  Copyright (c) 2015 Thinaire. All rights reserved.
//

#import "TADate.h"

NSDate *stringToDate(NSString *dateString)
{
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    [dateformatter setLocale:usLocale];
    [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateformatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    return[dateformatter dateFromString:dateString];
}

NSString *dateToISOFormat(NSDate *date)
{
    // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
    // Example: 2013-10-25T06:59:43.431Z
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS.SSS'Z'"];
    
    NSString* dateTimeInIsoFormatForZuluTimeZone = [dateFormatter stringFromDate:date];
    return dateTimeInIsoFormatForZuluTimeZone;
}
