//
//  Hospital.m
//  CureMe
//
//  Created by Tim on 12-8-30.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "Hospital.h"

@implementation Hospital

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize city = _city;
@synthesize telephone = _telephone;
@synthesize address = _address;
@synthesize introduction = _introduction;
@synthesize webSite = _webSite;
@synthesize topImageKey = _topImageKey;
@synthesize imageKey = _imageKey;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;


-(void)dealloc
{
    _name = nil;
    _city = nil;
    _telephone = nil;
    _address = nil;
    _introduction = nil;
    _webSite = nil;
    _topImageKey = nil;
    _imageKey = nil;
}

@end
