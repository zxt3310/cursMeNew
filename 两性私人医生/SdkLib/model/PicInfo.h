//
//  PicInfo.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface PicInfo : JSONModel

@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *size;
@property (nonatomic, strong)NSString * pic;
@property (nonatomic, strong)NSString * account;
@property (nonatomic, strong)NSString * url;
@property (nonatomic, strong)NSString *md5;

@end
