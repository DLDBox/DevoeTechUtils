//
//  TAUniqueIdentifier.h
//  Thinaire
//
//  Created by Dana L. DeVoe on 5/12/15.
//  Copyright (c) 2015 Thinaire. All rights reserved.
//

/* This object create a Unique Identifier for the device and will
 remain even after the app is uninstalled and re-install.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TADeviceIDType){
    TADeviceIDTypeAD,
    TADeviceIDTypeDevice
};

@interface TAUniqueIdentifier : NSObject

+ (NSString *)uniqueIdentifier;
+ (void)clearIdentifer;

+ (TADeviceIDType) identifierType;
+ (BOOL)userDisabledADID;


@end
