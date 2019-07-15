//
//  HisMsgParam.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface HisMsgParam : JSONModel

//static const int ORDER_ASC = 0;
//static const int ORDER_DESC = 1;
//static const long TIME_DEFAULT_VALUE = 0;
//static const int OFFSET_DEFAULT_VALUE =-1;

@property (nonatomic, assign)long chatId;
@property (nonatomic, assign)int limit;
@property (nonatomic, assign)int offset;
@property (nonatomic, assign)int order;
@property (nonatomic, assign)long time;
@property (nonatomic, strong)NSString *destUserId;

@end
