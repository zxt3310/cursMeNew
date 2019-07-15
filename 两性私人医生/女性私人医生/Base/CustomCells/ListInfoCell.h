//
//  ListInfoCell.h
//  CureMe
//
//  Created by Tim on 12-8-28.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


#define INFOCELL_HEIGHT 96


@interface InfoUnit : NSObject

@property NSInteger identifier;
@property NSInteger dataListType;   // 标明是医生信息还是医院信息
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, strong) NSString *imageKey;
@property NSInteger hospitalID;

@end



@class InfoListTableViewController;

@interface ListInfoCell : UITableViewCell

{
    UIImageView *headImage;
    UIImageView *headImageFrame;
    UILabel *nameLabel;
    UILabel *infoLabel;
    UILabel *introLabel;
}


// 显示的内容数据
@property (nonatomic, strong) InfoUnit *infoUnit;
@property (nonatomic, strong) InfoListTableViewController *viewController;

- (void)generateLayout;

@end
