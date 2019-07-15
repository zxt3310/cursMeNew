//
//  CMQAViewControllerTitleView.h
//  私密健康医生
//
//  Created by Tim on 13-1-13.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CMQAViewController;

@interface CMQAViewControllerTitleView : UIView

{
    bool isTypesExpanded;
}

@property (nonatomic) NSInteger officeID;
@property (nonatomic, strong) CMQAViewController *qaViewController;
@property (nonatomic, strong) UIImageView *titleIconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleTriangleView;

- (void)rotateTitleTriangle;

@end
