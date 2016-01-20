//
//  TAUniqueIdentifier.m
//  Thinaire
//
//  Created by Dana L. DeVoe on 5/12/15.
//  Copyright (c) 2015 Thinaire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUniqueIdentifier.h"
#import "SSKeychain.h"
#import "TALog.h"

static NSString *const kKeyChainServiceType = @"com.thinaire.ServiceType.UserID";
static NSString *const kKeyChainAccount = @"com.thinaire.Account.UserID";

//creating this object as replacement for advertisingIdentifier
@implementation TAUniqueIdentifier

+ (NSString *)uniqueIdentifier
{ // store the id in both the keychain and the NSUserDefaults.
    return [self adIdentifier] ?: [self deviceIdentifier];
}

+ (NSString *)adIdentifier
{
    id unInitAdID = NSClassFromString(@"ASIdentifierManager");
    
    if ( unInitAdID )
    {
        SEL sel_sharedManager = NSSelectorFromString(@"sharedManager");
        
        id obj_aSIdentifierManager = [unInitAdID performSelector:sel_sharedManager];
        
        if ( obj_aSIdentifierManager )
        {
            BOOL isTracking = (BOOL)[obj_aSIdentifierManager valueForKey:@"isAdvertisingTrackingEnabled"];
            
            if ( isTracking )
            {
                NSUUID *uuid = [obj_aSIdentifierManager valueForKey:@"advertisingIdentifier"];
                
                if ( uuid ) {
                    return [uuid UUIDString] ?: [self deviceIdentifier];
                }
                
            }
            else{
                WLog( @"Ad tracking is turned off" );
            }
        }
    }
    
    return [self deviceIdentifier];
}

+ (NSString *)deviceIdentifier
{
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
    
//    NSString *UUIDString = [SSKeychain passwordForService:kKeyChainServiceType account:kKeyChainAccount];
//    BOOL updateKeyChain = FALSE;
//    BOOL updateUserDefaults = FALSE;
//    
//    if (UUIDString == nil){
//        UUIDString = [[NSUserDefaults standardUserDefaults] stringForKey:kKeyChainServiceType];
//        updateKeyChain = YES;
//    }
//    
//    if (UUIDString == nil){
//        UUIDString = [UIDevice currentDevice].identifierForVendor.UUIDString;
//        updateUserDefaults = YES;
//    }
//    
//    NSError *error;
//    if ( updateKeyChain ) {
//        [SSKeychain setPassword:UUIDString forService:kKeyChainServiceType account:kKeyChainAccount error:&error];
//    }
//    
//    if ( updateUserDefaults ) {
//        [[NSUserDefaults standardUserDefaults] setObject:UUIDString forKey:kKeyChainAccount];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    
//    if (error) {
//        DLog( @"There was an error storing the UUID string in %s",__PRETTY_FUNCTION__ );
//    }
    
    //return UUIDString;
}

+ (void)clearIdentifer
{
    [SSKeychain deletePasswordForService:kKeyChainServiceType account:kKeyChainAccount];
}

+ (TADeviceIDType) identifierType
{
    id unInitAdID = NSClassFromString(@"ASIdentifierManager");
    
    if ( unInitAdID )
    {
        SEL sel_sharedManager = NSSelectorFromString(@"sharedManager");
        //IMP imp = [unInitAdID methodForSelector:sel_sharedManager];
        
        id obj_aSIdentifierManager = [unInitAdID performSelector:sel_sharedManager];
        
        if ( obj_aSIdentifierManager ){
            return TADeviceIDTypeAD;
        }
    }

    return TADeviceIDTypeDevice;
}

+ (BOOL)userDisabledADID
{
    id unInitAdID = NSClassFromString(@"ASIdentifierManager");
    
    if ( unInitAdID )
    {
        SEL sel_sharedManager = NSSelectorFromString(@"sharedManager");
        id obj_aSIdentifierManager = [unInitAdID performSelector:sel_sharedManager];
        
        if ( obj_aSIdentifierManager )
        {
            BOOL isTracking = (BOOL)[obj_aSIdentifierManager valueForKey:@"isAdvertisingTrackingEnabled"];
            
            if ( isTracking ){
                return NO;
            }
        }
    }
    
    return YES;
}


@end
