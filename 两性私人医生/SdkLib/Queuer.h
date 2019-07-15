//
//  Queuer.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/12.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BoBase.h"

@interface Queuer : NSObject

+(id)instance;

- (void)request:(JSONModel*)reqObj withResponse:(Class) responseCls Completed:(complete) callback;
- (void)request:(JSONModel*)reqObj withResponse:(Class) responseCls withBaseUrl:(NSString*) url Completed:(complete) callback;

@end
