//
//  BubbleViewController.h
//  CureMe
//
//  Created by Tim on 12-8-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableBaseViewController.h"
#import "CustomBaseViewController.h"
#import "UIBubbleTableViewDataSource.h"
#import "ImageDownloadHelper.h"
#import "EGORefreshTableHeaderView.h"
#import "ChatHospitalInfoCell.h"
#import "ChatPopupRemindView.h"
#import "CMMarkDoctorViewController.h"
#import "CMPickerViewController.h"
#import "CMQAProtocolView.h"

//20140519 jongs 增加无地域选择下立即查询需要选择地域

enum ScrollAdjustType {
    SCROLLTOEND = 0,
    SCROLLNONE
    };

// 当前聊天里的预约信息单DataSource
@interface ChatBookInfo : NSObject

@property NSInteger bookID;
@property (nonatomic, strong) NSString *hospitalName;
@property (nonatomic, strong) NSString *officeName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bookNumber;
@property NSInteger bookSucceed;
@property NSInteger age;
@property NSInteger officeID;
@property NSInteger hospitalID;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *memory;

@end


static bool needStopDetectReplies;

@class Doctor;
@class CMActionSheet;
@class XYLoadingView;
@class UIBubbleTableView;
@class CMQAOfficeSubTypeView;
@class LoadingView;

@interface BubbleViewController : CustomBaseViewController <UIBubbleTableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, EGORefreshTableHeaderDelegate, ImageDownloadHelperDelegate, CMMarkDoctorViewControllerDelegate, CMPickerDelegate,CMQuickAskLocationDeletage>

{
    IBOutlet UIBubbleTableView *bubbleTable;
//    IBOutlet UIButton *furtherTalkBtn;
    IBOutlet UIButton *addImageBtn;
    IBOutlet UIButton *sendMsgBtn;
    IBOutlet UIImageView *sendQuestionImage;
    IBOutlet UILabel *sendQuestionLabel;
    IBOutlet UIView *queryInputView;

    NSMutableArray *bubbleData;
    NSMutableDictionary *doctorImages;
    NSMutableDictionary *doctorNames;
    NSMutableDictionary *doctorIDImageKeys;
    ImageDownloadHelper *imageDownloader;
    
    ChatPopupRemindView *popupRemindView;
    
    // Drag refresh datas
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSInteger oldesMessageTime;    
    
    // 聊天过程中，生成的
    NSInteger chatBookID;
    
    // 上一次咨询的问题内容
    NSString *lastQueryString;
    CMQAOfficeSubTypeView *subTypeView;
    
    // 显示咨询View时，临时保存右侧BarButtonItem
    UIBarButtonItem *rightBarItem;
    NSString *navTitle;
    // 显示咨询View时，显示“确定咨询”按钮
    UIBarButtonItem *confirmRightBarItem;
    
    // 为医生打分的ViewController
    CMMarkDoctorViewController *markDoctorViewController;
    
    // 评价数据
    NSInteger chatMarkPoint;    // 评分
    NSString *chatMarkComment;  // 评价内容
    
    LoadingView *loadingView;
    
    //jongs add 20140519
    // 选择省份的VC
    CMPickerViewController *pickerViewController;
}

// 用户咨询时选择的科室子分类
@property NSInteger officeSubType;

@property (nonatomic, strong) Doctor *doctor;
@property (nonatomic, strong) NSString *chatOpenType;
@property (nonatomic, strong) BookInfoUnit *bookInfoUnit;
@property double hospitalLongitude;
@property double hospitalLatitude;

// 聊天记录上方，显示医院医生信息的DataSource
@property (nonatomic, readonly, strong) ChatMetaInfoData *metaInfoData;
@property (nonatomic, strong, readonly) UIImage *doctorHeadImage;
@property bool isTalkFromSelfQuestion;
@property NSInteger chatID;
@property NSString *pageName;
@property NSString *sourceType;
@property NSInteger chatUserID;
@property NSInteger sourceID;   // 源ID，可能是reply，可能是doctor

@property (strong, nonatomic) IBOutlet UITextField *inputField;
@property (strong, nonatomic) IBOutlet UILabel *lineLb;
@property NSInteger officeType;

// 发起评价事件
- (IBAction)startMarkChat:(id)sender;

// 立即咨询View
@property (strong, nonatomic) IBOutlet UIView *startQueryView;
- (IBAction)startQueryBtnClicked:(id)sender;
- (IBAction)startBookBtnClicked:(id)sender;

// 发送咨询输入View
- (IBAction)sendQueryBtnClicked:(id)sender;


@property (nonatomic, strong) NSString *talkerName;
@property NSInteger talkerID;

- (void)threadGetChatBookInfo;
- (void)getChatBookInfo;

- (NSMutableDictionary *)doctorNames;
- (NSString *)doctorNameWithDoctorID:(NSInteger)doctorID;

- (UIImage *)metaDataImageWithImageKey:(NSString *)imageKey;
- (UIImage *)doctorHeadImageWithImageKey:(NSString *)imageKey;

- (ImageDownloadHelper *)imageDownloader;

// 初始化子分类View
- (void)initSubTypeView;
// 初始化咨询时Bar右侧确认按钮
//- (void)initQueryRightBarItem;

- (void)initTalkData;
- (void)initChatIDAndTalkData;
- (void)showMsgLimitAlert;
- (void)initChatMetaData;
- (void)initMarkData:(NSDictionary *)data;

- (void)addHistoryMessageArray:(NSArray *)msgArray;
- (bool)addSingleHisMessage:(NSDictionary *)messageOriginal;

// 医生信息，并下载获取医生头像
- (void)addDoctorsInfo:(NSArray *)doctors;

- (IBAction)attachPicture:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)startSelfTalk:(id)sender;
- (IBAction)startQuery:(id)sender;
- (IBAction)startBooking:(id)sender;

// 启动准备显示Remind文字的Timer，可在非UI线程中调用，Interval为等待显示的时间
// 如果在其他线程中调用，需要在MainThread里perform selector
- (void)startRemindViewTimer:(NSDictionary *)userInfo;
// 直接显示Remind文字，必须在UI线程中调用
- (void)showRemindView:(NSTimer *)timer;

- (void)takePicture;
- (void)openPhotoLibrary;
- (void)openSavedPhotoLibrary;

- (void)reloadData:(NSNumber *)scrollAdjustType;

- (void)loadNextPageHistory;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)loadMoreHistoryMessage;
- (void)threadLoadMoreHistoryMessage;

#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (void)threadSendImage:(UIImage *)image;
- (void)mainThreadAddBubbleData:(NSBubbleData *)chatData;
- (void)threadGetImage:(NSDictionary *)userInfo;

- (void)threadGetDoctorHeadImage:(NSString *)imageKey;
- (void)threadInitChatDatas;
- (void)threadDetectReplies;

- (void)ntfUpdateUnreadMsgCount:(NSNotification *)note;
- (void)ntfPullNewMsgs:(NSNotification *)note;
- (void)ntfShowFullImage:(NSNotification *)note;

- (void)showOfficeListPage;
- (void)showDoctorDetailPage;
- (void)showBookingPage;
- (void)showHospitalDetailPage;
- (void)showHospitalMapPage;

- (void)sendBookActionResponse:(NSString *)action andBookID:(NSInteger)bookID;

- (void)popPickerView;

- (void)closeKeyboard;

@end
