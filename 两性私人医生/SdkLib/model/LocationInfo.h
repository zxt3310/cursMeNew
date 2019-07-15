//
//  LocationInfo.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"
#import "Coord.h"

@interface LocationInfo : JSONModel

typedef enum {
    
    LOCATION_GPS = 1,
    LOCATION_NETWORK = 2
    
} LOCATION_TYPE;

@property (nonatomic, assign)int type;
@property (nonatomic, strong)NSString *province;
@property (nonatomic, strong)NSString *city;
@property (nonatomic, strong)Coord *coord;
@property (nonatomic, strong)NSString *district;

-(id)init;

@end
