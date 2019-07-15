//
//  CMCustomViews.h
//  私密健康医生
//
//  Created by Tim on 13-1-23.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCustomViews : UIView

@end


// 正在载入的View
@interface LoadingView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *loadingImage;
@property (nonatomic, strong) UILabel *dscpLabel;

@end

// TableView无数据的通用View
@interface NoDataBackgroundView : UIView

@property (nonatomic, strong) UIImageView *warningImage;
@property (nonatomic, strong) UILabel *warningLabel;

@end
