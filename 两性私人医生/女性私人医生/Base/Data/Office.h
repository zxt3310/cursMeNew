//
//  Office.h
//  CureMe
//
//  Created by Tim on 12-8-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Office : NSObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSNumber *hospitalID;
@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *type;

@end
