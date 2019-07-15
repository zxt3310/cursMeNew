//
//  UIBubbleTableViewMapInfoCell.m
//  CureMe
//
//  Created by Tim on 12-11-2.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "NSBubbleData.h"
#import "UIBubbleTableViewMapInfoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIBubbleTableViewMapInfoCell

@synthesize dataInternal = _dataInternal;
@synthesize bubbleViewController = _bubbleViewController;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = YES;
        
        // 背景
        background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].chatNotifyBubbleImage];
        [background setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:background];
        
        // 消息时间Label
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setTextAlignment:UITextAlignmentCenter];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setHidden:YES];
        [self.contentView addSubview:headerLabel];

        // 经纬度信息Label
        addrInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [addrInfoLabel setFont:[UIFont systemFontOfSize:12]];
        [addrInfoLabel setTextColor:[UIColor whiteColor]];
        [addrInfoLabel setBackgroundColor:[UIColor clearColor]];
        [addrInfoLabel setShadowColor:[UIColor darkGrayColor]];
        [addrInfoLabel setShadowOffset:CGSizeMake(1, 1)];
        [addrInfoLabel setTextAlignment:UITextAlignmentCenter];
        [addrInfoLabel setNumberOfLines:1];
        [addrInfoLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.contentView addSubview:addrInfoLabel];

        // 定位小箭头Image
        pinImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_point.png"]];
        [pinImage setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:pinImage];
        
        mapImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [mapImage setBackgroundColor:[UIColor clearColor]];
        mapImage.image = [UIImage imageNamed:@"地图.png"];
//        [mapImage setUserInteractionEnabled:YES];
//        [mapImage.layer setBorderColor:[UIColor colorWithRed:249.0/255 green:208.0/255 blue:214.0/255 alpha:1.0].CGColor];
//        [mapImage.layer setCornerRadius:4.0];
//        [mapImage setClipsToBounds:YES];
//        [mapImage.layer setBorderWidth:2.0];
        [self.contentView addSubview:mapImage];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataInternal:(NSBubbleDataInternal *)dataInternal
{
    _dataInternal = dataInternal;
}

- (void)setBubbleViewController:(BubbleViewController *)bubbleViewController
{
    _bubbleViewController = bubbleViewController;
    
    if (_bubbleViewController) {
        _latitude = _bubbleViewController.hospitalLatitude;
        _longitude = _bubbleViewController.hospitalLongitude;
    }
    
//    if (!image) {
//        [self performSelectorInBackground:@selector(threadGetMapImage) withObject:nil];
//    }
    
    [self generateLayout];
}

- (void)generateLayout
{
    if (_latitude < -90 || _latitude > 90 || _longitude < -180 || _longitude > 180) {
        NSLog(@"Bubble Cell location data invalid %.2f %.2f", _latitude, _longitude);
        return;
    }
    
    float inset = 4.0;
    float timeHeader = 0;
    if (self.dataInternal.header) {
        timeHeader = 30;
        headerLabel.hidden = NO;
        headerLabel.text = self.dataInternal.header;
    }
    else {
        headerLabel.hidden = YES;
    }
    
//    if (image)
//        mapImage.image = image;
    background.frame = CGRectMake(65, timeHeader, 190, 60);
    pinImage.frame = CGRectMake(60 + 10 + inset, timeHeader + inset * 2, 20, 26);
    [mapImage setFrame:CGRectMake(60 + 40, timeHeader + inset, 115, 35)];
    
//    if (_dataInternal)
//        addrInfoLabel.text = _dataInternal.data.text;
//    else
//        addrInfoLabel.text = [[NSString alloc] initWithFormat:@"点击查看详情(%.2f %.2f)", _latitude, _longitude];

    addrInfoLabel.text = [[NSString alloc] initWithFormat:@"点击查看我院位置(%.2f %.2f)", _latitude, _longitude];
    [addrInfoLabel setFrame:CGRectMake(60 + inset, timeHeader + 40, 200 - inset * 2, 15)];
}

- (void)threadGetMapImage
{
//    // http://api.map.baidu.com/staticimage?width=400&height=300&center=116.463162,39.918929&zoom=15&markers=116.463809,39.919538&markerStyles=m,H
//    @autoreleasepool {
//        NSString *url = [[NSString alloc] initWithFormat:@"http://api.map.baidu.com/staticimage?width=200&height=200&center=%.2f,%.2f&zoom=15&markers=%.2f,%.2f&markerStyles=m,H", _longitude, _latitude, _longitude, _latitude];
//        NSData *response = sendGETRequest(url);
//
//        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//        NSLog(@"strResp: %@", strResp);
//        
//        image = [[UIImage alloc] initWithData:response];
//        
//        [self performSelectorOnMainThread:@selector(mainThreadRefresh) withObject:nil waitUntilDone:NO];
//    }
}

- (void)mainThreadRefresh
{
    if (!_bubbleViewController)
        return;
    
    [_bubbleViewController reloadData:[[NSNumber alloc] initWithInt:SCROLLNONE]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_bubbleViewController && [_bubbleViewController respondsToSelector:@selector(showHospitalMapPage)]) {
        [_bubbleViewController showHospitalMapPage];
    }

//    UITouch *touch = [event.allTouches anyObject];
//    if ([touch.view isKindOfClass:[UIImageView class]]) {
//        // 显示地图
//        [_bubbleViewController showHospitalMapPage];
//    }
}

@end
