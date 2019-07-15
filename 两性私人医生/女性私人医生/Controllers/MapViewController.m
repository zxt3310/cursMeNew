//
//  MapViewController.m
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "MapViewController.h"
#import "BMKAnnotation.h"
#import "BMKMapView.h"


@implementation DisplayMap
@synthesize coordinate,title,subtitle;

-(void)dealloc{
    title = nil;
    subtitle = nil;
}

@end


@interface MapViewController ()

@end

@implementation MapViewController

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize hospitalName = _hospitalName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        locationManager = [[CLLocationManager alloc] init];
//        [locationManager setDelegate:self];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [locationManager startUpdatingLocation];
    CLLocationCoordinate2D coord;
    if (_latitude >= -90 && _latitude <= 90 && _longitude >= -180 && _longitude <= 180) {
        coord.latitude = _latitude;
        coord.longitude = _longitude;
    }
    else {
        coord.latitude = _latitude = 39.9093;
        coord.longitude = _longitude = 116.3976;
        //        [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    float zoomLevel = 0.018;
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    
    DisplayMap *ann = [[DisplayMap alloc] init];
    ann.title = _hospitalName;
    //地点名字
    ann.coordinate = region.center;
    [_mapView addAnnotation:ann];
    [_mapView setRegion:region];

//	BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc] init];
//	CLLocationCoordinate2D coor;
//	coor.latitude = _latitude;
//	coor.longitude = _longitude;
//	annotation.coordinate = coor;
//	annotation.title = _hospitalName;
//	[mapView addAnnotation:annotation];
//    NSLog(@"BMKMapView: %@", mapView);
    
    [self.navigationItem setTitle:[[NSString alloc] initWithFormat:@"%@ 定位", _hospitalName]];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    _mapView = nil;
}

#pragma mark MKMapViewDelegate
// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
		BMKPinAnnotationView *newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
		newAnnotation.pinColor = BMKPinAnnotationColorPurple;
		newAnnotation.animatesDrop = YES;
		newAnnotation.draggable = YES;
		
		return newAnnotation;
	}
	return nil;
}

//- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    MKPinAnnotationView *pinView = nil;
//    if(annotation != mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"com.invasivecode.pin";
//        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil )
//            pinView = [[MKPinAnnotationView alloc]
//                                          initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//        pinView.pinColor = MKPinAnnotationColorPurple;
//        pinView.canShowCallout = YES;
//        pinView.animatesDrop = YES;
//    }
//    else {
//        [mapView.userLocation setTitle:_hospitalName];
//    }
//    return pinView;
//}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
//    //获取所在地城市名
//    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
//    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks,NSError *error)
//     {
//         NSString *currentCity = nil;
//         for(CLPlacemark *placemark in placemarks)
//         {
//             currentCity=[[placemark.addressDictionary objectForKey:@"City"] substringToIndex:2];
//             NSLog(@"str%@",currentCity);
//         }
//     }];
    [locationManager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
