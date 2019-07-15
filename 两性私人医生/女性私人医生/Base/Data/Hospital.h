//
//  Hospital.h
//  CureMe
//
//  Created by Tim on 12-8-30.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hospital : NSObject

@property NSInteger identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *webSite;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, strong) NSString *topImageKey;
@property (nonatomic, strong) NSString *imageKey;
@property double longitude;
@property double latitude;

@end
