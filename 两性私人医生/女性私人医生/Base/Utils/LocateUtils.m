//
//  LocateUtils.m
//  CureMe
//
//  Created by Tim on 12-10-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "LocateUtils.h"


@interface LocateUtils (Private)
- (void)startAdjustCoordinate;
@end


@implementation LocateUtils

@synthesize baiduLongitude = _baiduLongitude;
@synthesize baiduLatitude = _baiduLatitude;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        @try {
            _baiduLongitude = nil;
            _baiduLatitude = nil;
            _province = nil;
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
        }
    }
    
    return self;
}

- (void)dealloc
{
    _mapView.showsUserLocation = NO;
    _mapView = nil;
    [_locService stopUserLocationService];
    _locService = nil;
    [_mapManager stop];
    _mapSearch = nil;
}

#pragma mark - BMKGeneralDelegate

- (void)onGetNetworkState:(int)iError
{
    
}

- (void)onGetPermissionState:(int)iError
{
    
}

#pragma mark - BMKLocationServiceDelegate

- (void)didFailToLocateUserWithError:(NSError *)error
{
    //    [lpLocalInfo cancelPreviousPerformRequestsWithTarget:self];
    NSLog(@"%@", error);
    
    [self stopUpdating];
    
    if ( [_delegate respondsToSelector:@selector(localInfoLocationUpdateFailed:)] )
        [_delegate localInfoLocationUpdateFailed:self];
    
    // 获得地址信息失败，提交错误统计
    NSString *post = [[NSString alloc] initWithFormat:@"action=addrdetaillog&error=%@", [[error description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"action=addrdetaillog resp: %@", strResp);
}

- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //    [self stopUpdating];
    
    self.baiduLongitude = [NSString stringWithFormat:@"%lf", userLocation.location.coordinate.longitude];
    self.baiduLatitude = [NSString stringWithFormat:@"%lf", userLocation.location.coordinate.latitude];
    
    NSLog( @"location: lo %@, la %@", _baiduLongitude, _baiduLatitude );
    
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    [_mapSearch reverseGeoCode:reverseGeoCodeSearchOption];
    
    //[_mapSearch reverseGeocode:userLocation.location.coordinate];
    [self startAdjustCoordinate];
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if ( result.addressDetail.province.length == 0 ) {
        return;
    }

    _province = result.addressDetail.province;
    _city = result.addressDetail.city;
    _district = result.addressDetail.district;
    _streetName = result.addressDetail.streetName;
    _streetNumber = result.addressDetail.streetNumber;
    
    //新增虚拟定位
    NSString *addressStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emulateLocationAddress"];
    if (addressStr || addressStr.length > 0) {
        _province = [[NSUserDefaults standardUserDefaults] objectForKey:EMULATE_LOCATION_PROVINCE];
        _city = [[NSUserDefaults standardUserDefaults] objectForKey:EMULATE_LOCATION_CITY];
        _district = [[NSUserDefaults standardUserDefaults] objectForKey:EMULATE_LOCATION_CITY];
    }
    
    NSLog( @"address: %@, %@, %@, %@, %@", _province, _city, _district, _streetName, _streetNumber );
    
    if ( [_delegate respondsToSelector:@selector(localInfoLocationUpdateSuccess:)] )
        [_delegate localInfoLocationUpdateSuccess:self];
    
    [self stopUpdating];
}

- (void)save
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          nil == _baiduLatitude ? @"" : _baiduLatitude, @"Addr_BaiduLatitude",
                          nil == _baiduLongitude ? @"" : _baiduLongitude, @"Addr_BaiduLongitude",
                          nil == _province ? @"" : _province , @"Addr_Province",
                          nil == _city ? @"" : _city, @"Addr_City",
                          nil == _district ? @"" : _district, @"Addr_District",
                          nil == _streetName ? @"" : _streetName, @"Addr_StreetName",
                          nil == _streetNumber ? @"" : _streetNumber, @"Addr_streetNumber",
                          nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LOCATION_ADDRESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_ADDRESS];

    if (!dict) {
        return;
    }
    
    self.baiduLatitude = [dict valueForKey:@"Addr_BaiduLatitude"];
    self.baiduLongitude = [dict valueForKey:@"Addr_BaiduLongitude"];
    self.province = [dict valueForKey:@"Addr_Province"];
    self.city = [dict valueForKey:@"Addr_City"];
    self.district = [dict valueForKey:@"Addr_District"];
    self.streetName = [dict valueForKey:@"Addr_StreetName"];
    self.streetNumber = [dict valueForKey:@"Addr_streetNumber"];
    
    if ( [_delegate respondsToSelector:@selector(localInfoLocationLoadComplete:)] )
        [_delegate localInfoLocationLoadComplete:self];
}


- (void)startUpdating
{
    if (!_mapManager) {
        // 开始定位
        _mapManager = [[BMKMapManager alloc] init];
        if (!_mapManager) {
            NSLog(@"BMKMapManager created nil");
        }
        else {
            //                [_mapManager start:@"8C530589D4AFB1A344A9384E92B4FC377E3F9FAC" generalDelegate:self];
            //[_mapManager start:@"9C9F249AA69E4304B1A84AD4835C574C3547199C" generalDelegate:self];
            [_mapManager start:@"UuFbq7GOVjhllQL3vq5ENDCpQUhB60OR" generalDelegate:self];
        }
        _locService = [[BMKLocationService alloc]init];
        
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectZero];
        _mapView.delegate = self;
        
        _locService.delegate = self;
        
        _mapSearch = [[BMKGeoCodeSearch alloc] init];
        _mapSearch.delegate = self;
    }
    
    [self stopUpdating];
    [_locService startUserLocationService];
    //_mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

- (void)stopUpdating
{
    //    [_mapManager stop];
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

@end


#pragma mark -
@implementation LocateUtils (Private)

- (void)startAdjustCoordinate
{
//    lpParameterGetCoordinate *param = [[lpParameterGetCoordinate alloc] init];
//    lpHttpRequest *request = [_httpManager requestWithParameters:param];
    
//    param.longitude_lo = self.baiduLongitude;
//    param.latitude_la = self.baiduLatitude;
//    
//    [_httpManager startRequest:request];
}

@end



