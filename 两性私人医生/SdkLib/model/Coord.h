//
//  Coord.h
//  HiChat
//
//  Created by xiaoshoucun on 15/10/29.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "JSONModel.h"

@interface Coord : JSONModel

@property (nonatomic, strong)NSString *longitude;
@property (nonatomic, strong)NSString *latitude;

@end