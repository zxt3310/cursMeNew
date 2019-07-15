//
//  ReqParam.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface ReqParam : JSONModel

@property (nonatomic, strong)NSString *userId;
@property (nonatomic, assign)int chatFlag;
@property (nonatomic, assign)long chatType;
@property (nonatomic, strong)NSString *customerNickName;
@property (nonatomic, strong)NSString *serviceNickName;
@property (nonatomic, strong)NSString *startDate;
@property (nonatomic, strong)NSString *endDate;
@property (nonatomic, assign)int pageSize;
@property (nonatomic, assign)int curPage;

- (id)init;

@end
