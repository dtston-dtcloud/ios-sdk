//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "NSString+Helper.h"
#import<SystemConfiguration/CaptiveNetwork.h>

@implementation NSString (Helper)

- (BOOL)isMobileNumber
{
    NSString * phoneRegex = @"^[1][34578][0-9]{9}$";
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL isMatch = [pre evaluateWithObject:self];
    return isMatch;
}

- (BOOL)isRegexPassword
{
    NSString * phoneRegex = @"^[0-9a-zA-Z_@.]{6,20}";
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL isMatch = [pre evaluateWithObject:self];
    return isMatch;
    
}
@end
