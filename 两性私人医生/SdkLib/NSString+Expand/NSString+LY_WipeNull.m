
//  hh
//
//  Created by QunjieHe on 13-7-5.
//  Copyright (c) 2013年 QunjieHe. All rights reserved.
//

#import "NSString+LY_WipeNull.h"

@implementation NSString (LY_WipeNull)

+ (NSString *)WipeNull:(NSString *)__str
{
    if(![__str isKindOfClass:[NSString class]] && __str != nil){
        return [NSString stringWithFormat:@"%@",__str];
    }
    
    
    if([__str isEqualToString:@"(null)"]){
        return @"";
    }
    if([__str isEqualToString:@"（null）"]){
        return @"";
    }
    if(__str == nil){
        return @"";
    }
    return __str;
}




@end
