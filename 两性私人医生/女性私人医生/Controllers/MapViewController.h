//
//  MapViewController.h
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import "BMapKit.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <UIKit/UIKit.h>


@interface DisplayMap : NSObject
<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end

@interface MapViewController : CustomBaseViewController <BMKMapViewDelegate>

{
    CLLocationManager *locationManager;
    
//    BMKMapManager *mapManager;
//    BMKMapView* mapView;
}

@property double latitude;
@property double longitude;
//@property (strong, nonatomic) IBOutlet BMKMapView *mapView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSString *hospitalName;
@end
