//
//  Doctor.m
//  CureMe
//
//  Created by Tim on 12-8-29.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Doctor.h"

@implementation Doctor

@synthesize doctorID = _doctorID;
@synthesize name = _name;
@synthesize title = _title;
@synthesize hospitalID = _hospitalID;
@synthesize hospitalName = _hospitalName;
@synthesize officeID = _officeID;
@synthesize officeName = _officeName;
@synthesize introduction = _introduction;
@synthesize imageKey = _imageKey;
@synthesize isOnline = _isOnline;

-(void)dealloc
{
    _name = nil;
    _title = nil;
    _hospitalName = nil;
    _officeName = nil;
    _introduction = nil;
}

@end
