//
//  LocateUtils.h
//  CureMe
//
//  Created by Tim on 12-10-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"


@class LocateUtils;

@protocol LocateUtilsDelegate <NSObject>
@optional
- (void)localInfoLocationWillStartUpdate:(LocateUtils *)localInfo;
- (void)localInfoLocationUpdateSuccess:(LocateUtils *)localInfo;
- (void)localInfoLocationUpdateFailed:(LocateUtils *)localInfo;
- (void)localInfoLocationLoadComplete:(LocateUtils *)localInfo;
@end

@interface LocateUtils : NSObject <BMKGeneralDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

{    
    BMKMapManager *_mapManager;
    BMKMapView *_mapView;
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_mapSearch;
}

@property (nonatomic, assign) id<LocateUtilsDelegate> delegate;
// coordinate from baidu map
@property (nonatomic, copy) NSString *baiduLongitude;
@property (nonatomic, copy) NSString *baiduLatitude;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *streetName;
@property (nonatomic, copy) NSString *streetNumber;

- (void)startUpdating;
- (void)stopUpdating;
- (void)load;
- (void)save;

@end
