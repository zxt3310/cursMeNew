//
//  Doctor.h
//  CureMe
//
//  Created by Tim on 12-8-29.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Doctor : NSObject

@property NSInteger doctorID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property NSInteger hospitalID;
@property (nonatomic, strong) NSString *hospitalName;
@property NSInteger officeID;
@property (nonatomic, strong) NSString *officeName;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, strong) NSString *imageKey;
@property bool isOnline;

@end
