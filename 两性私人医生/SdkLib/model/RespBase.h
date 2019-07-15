
//
//  RespBase.h
//
//  Created by xiaoshoucun on 15/11/2.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface RespBase : JSONModel

@property (nonatomic, assign)int actionId;
@property (nonatomic, assign)int code;
@property (nonatomic, strong)NSString *message;
@property (nonatomic, strong)NSString *userAccount;
@property (nonatomic, assign)long chatId;

@end
