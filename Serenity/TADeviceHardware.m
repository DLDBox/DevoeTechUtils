//
//  TADeviceHardware.m
//  ThinaireController
//
//  Created by Dana Devoe on 9/9/15.
//  Copyright (c) 2015 Google. All rights reserved.
//

#import "TADeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation TADeviceHardware

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";

    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";

    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6+";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1 G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2 G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3 G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4 G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5 G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6 G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 G";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 G";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 G";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 G";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 G";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 G";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 G";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air 1 G";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air 1 G";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air 1 G";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 G";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 G";
    
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini 1 G";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini 1 G";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini 1 G";
    
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2 G";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2 G";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad mini 2 G";
    
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad mini 3 G";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad mini 3 G";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad mini 3 G";
    
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini 1 G";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

- (BOOL) supportBluetoothSmart
{
    NSString *platform = [self platformString];
    NSArray *segments = [platform componentsSeparatedByString:@" "];
    
    if ( [segments.firstObject isEqualToString:@"iPhone"] ) {
        return ([platform containsString:@"4"] && ![platform containsString:@"4S"]) ||
               [platform containsString:@"3"] || [platform containsString:@"2"] ||
                [platform containsString:@"1"]    ;
    }
    
    if ( [segments.firstObject isEqualToString:@"iPad"] ) {
        return [platform containsString:@"2"] || [platform containsString:@"1"];
    }
    
    if ( [segments.firstObject isEqualToString:@"iPod"] ) {
        return [platform containsString:@"1"] || [platform containsString:@"2"];
    }
    
    
    return TRUE;
}

@end
