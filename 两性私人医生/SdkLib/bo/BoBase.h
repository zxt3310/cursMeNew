//
//  BoBase.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "JSONModel+networking.h"

typedef void(^complete)(NSObject *request, NSObject *data, int code);

@protocol BoBase @end

@interface BoBase : NSObject

@property (nonatomic, strong)Class responseCls;

- (void)request:(JSONModel*)reqObj Completed:(complete) callback;
- (void)request:(JSONModel*)reqObj withBaseUrl:(NSString*) url Completed:(complete) callback;

@end
