//
//  DataUtils.m
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "DataUtils.h"


static CMDataUtils *defaultDataU;



// 用于“我的对话”列表
#pragma mark 我的对话列表Cell数据
@implementation MyChatInfoUnit

@end


// 用于“我的预约”列表
#pragma mark 预约概要信息数据
@implementation BookInfoUnit

- (NSString *)description
{
    NSString *dscp = [NSString stringWithFormat:@"BookInfoUnit:\nbookID: %ld\nbookNumber: %@\nhospID: %ld\nofficeID: %ld\nuserName: %@\nbookDate: %@\nbookState: %ld\nhospName: %@\nofficeName: %@\ndoctorName: %@\ndoctorInfo: %@\ndoctorReply: %@\nmemory: %@\nimageKey: %@\n", (long)_bookID, _bookNumber, (long)_hospitalID, (long)_officeID, _userName, _bookDate, (long)_bookState, _hospitalName, _officeName, _doctorName, _doctorInfo, _doctorReply, _memory, _doctorImageKey];
    
    return dscp;
}

@end


#pragma mark 预约详情数据
// 预约详情数据结构
@implementation BookDetail

- (NSString *)debugDescription
{
    NSString *dscp = [[NSString alloc] initWithFormat:@"\nbookID: %ld\nbookNo: %@\nsucceed: %ld\nName: %@\nHospname: %@\nOffName: %@\nHospID: %ld\nOffID: %ld\nBookTime: %@\nTelephone: %@\nage: %ld\nMemory: %@\nHospReply: %@\nHospImage: %@\n", (long)_bookID, _bookNumber, (long)_succeed, _name, _hospitalName, _officeName, (long)_hospitalID, (long)_officeID, _bookTime, _telephone, (long)_age, _memory, _hospitalReply, _hospitalImage];
    
    return dscp;
}

@end


#pragma mark OfficeTypeUnit
@implementation OfficeTypeUnit

+ (OfficeTypeUnit *)unitWithID:(NSInteger)officeID andName:(NSString *)officeName andIcon:(UIImage *)officeIcon
{
    OfficeTypeUnit *newUnit = [[OfficeTypeUnit alloc] init];
    newUnit.officeID = officeID;
    newUnit.officeName = officeName;
    newUnit.officeIcon = officeIcon;
    
    return newUnit;
}

@end


#pragma mark OfficeSubTypeUnit
@implementation OfficeSubTypeUnit

@synthesize subTypeID = _subTypeID;
@synthesize parentTypeID = _parentTypeID;
@synthesize subTypeName = _subTypeName;

- (Class)classForCoder
{
    return [self class];
}

- (void)initWithCoder:(NSCoder *)decoder
{
    self.subTypeName = [decoder decodeObjectForKey:@"SubTypeName"];
    self.parentTypeID = [decoder decodeObjectForKey:@"ParentTypeID"];
    self.subTypeID = [decoder decodeObjectForKey:@"SubTypeID"];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_subTypeName forKey:@"SubTypeName"];
    [encoder encodeObject:_parentTypeID forKey:@"ParentTypeID"];
    [encoder encodeObject:_subTypeID forKey:@"SubTypeID"];
}

@end


#pragma mark CMDataUtils
@interface CMDataUtils(PrivateMethods)

- (void)threadInitAllOfficeSubTypeData;

@end


@implementation CMDataUtils

@synthesize officeTypeArray = _officeTypeArray;
@synthesize officeTypeDict = _officeTypeDict;
@synthesize officeSuperTypeDict = _officeSuperTypeDict;

+ (CMDataUtils *)defaultDataUtil
{
    if (!defaultDataU) {
        defaultDataU = [[super allocWithZone:NULL] init];
    }
    
    return defaultDataU;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultDataUtil];
}

- (id)init
{
    if (defaultDataU) {
        return defaultDataU;
    }
    
    self = [super init];
    
    // CMDataUtils Initialization work

    return self;
}

- (NSArray *)officeTypeArray
{
    if (!_officeTypeArray) {
        _officeTypeArray = [NSArray arrayWithObjects:
                            /*[OfficeTypeUnit unitWithID:OFFICE_MEIRONG andName:@"美容" andIcon:[UIImage imageNamed:@"ico_ck_n.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_FUKE andName:@"妇科" andIcon:[UIImage imageNamed:@"ico_fk_n.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_CHANKE andName:@"产科" andIcon:[UIImage imageNamed:@"ico_ck_n.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_PIFUKE andName:@"皮肤科" andIcon:[UIImage imageNamed:@"ico_pfk_n.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_YANKE andName:@"眼科" andIcon:[UIImage imageNamed:@"ico_yk_n.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_KOUQIANG andName:@"口腔" andIcon:[UIImage imageNamed:@"ico_kouqiang.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_JIAKANG andName:@"甲状腺" andIcon:[UIImage imageNamed:@"ico_jiakang.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_GANBING andName:@"肝病科" andIcon:[UIImage imageNamed:@"ico_ganbing.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_NAOTAN andName:@"脑瘫科" andIcon:[UIImage imageNamed:@"ico_naobu.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_GUKE andName:@"骨科" andIcon:[UIImage imageNamed:@"ico_gutou.png"]],
                            [OfficeTypeUnit unitWithID:OFFICE_DIANXIAN andName:@"癫痫科" andIcon:[UIImage imageNamed:@"ico_dianxian.png"]],*/
                            [OfficeTypeUnit unitWithID:OFFICE_MEIRONG andName:@"美容" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_FUKE andName:@"妇科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_CHANKE andName:@"产科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_PIFUKE andName:@"皮肤科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_YANKE andName:@"眼科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_KOUQIANG andName:@"口腔" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_JIAKANG andName:@"甲状腺" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_GANBING andName:@"肝病科" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_NAOTAN andName:@"脑瘫科" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_GUKE andName:@"骨科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_DIANXIAN andName:@"癫痫科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_BYBY andName:@"不孕不育" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_XINZANG andName:@"心脏科" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_SHENJING andName:@"神经科" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_ERBIHOU andName:@"耳鼻喉" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_WEICHANG andName:@"胃肠科" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_TANGNIAOBING andName:@"糖尿病" andIcon:nil],
                            //[OfficeTypeUnit unitWithID:OFFICE_ZHONGLIU andName:@"肿瘤" andIcon:nil],
                            [OfficeTypeUnit unitWithID:OFFICE_GANGCHANG andName:@"肛肠科" andIcon:nil],
                            nil];
    }
    
    return _officeTypeArray;
}

- (void)initAllOfficeSubTypeData
{
    [self performSelectorInBackground:@selector(threadInitAllOfficeSubTypeData) withObject:nil];
}

// {"result":true,"msg":[{"id":11,"name":"\u9686\u80f8","parent":10},{"id":12,"name":"\u9686\u9f3b","parent":10},{"id":13,"name":"\u8138\u90e8\u6574\u5f62","parent":10},{"id":14,"name":"\u7f8e\u77b3","parent":10},{"id":15,"name":"\u4fee\u624b","parent":10},{"id":16,"name":"\u81c0\u90e8\u7f8e\u5bb9","parent":10},{"id":17,"name":"\u5176\u4ed6","parent":10}]}
- (void)threadInitAllOfficeSubTypeData
{
    @autoreleasepool {
        // 先用本地保存的子分类科室初始化
        NSData *archData = [[NSUserDefaults standardUserDefaults] objectForKey:OFFICE_SUBTYPE_DICT];
        _officeTypeDict = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
        archData = [[NSUserDefaults standardUserDefaults] objectForKey:OFFICE_SUPERTYPE_ARRAY];
        _officeSuperTypeDict = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
        
        if (!_officeTypeDict) {
            _officeTypeDict = [[NSMutableDictionary alloc] init];
        }
        NSLog(@"officeSubTypeData: %@", _officeTypeDict);
        
        NSString *urlStr = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/m.php?action=getallqtypebyappidandgps&version=3.0&appid=4&source=apple&addrdetail=%@",[CureMeUtils defaultCureMeUtil].encodedLocateInfo];
        
        //NSString *post = [NSString stringWithFormat:@"action=questiontypechild"];
        //NSData *response = sendRequest(@"m.php", post);
        NSData *response = sendFullRequest(urlStr, nil, nil, NO, NO);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=questiontypechild resp: %@", strResp);
        
        NSDictionary *jsonData = parseJsonResponse(response);
        if (!jsonData || jsonData.count <= 0) {
            NSLog(@"action=questiontypechild json invalid: %@", strResp);
            return;
        }
        
        NSNumber *result = [jsonData objectForKey:@"result"];
        if (!result || result.integerValue != 1) {
            NSLog(@"action=questiontypechild json result invalid: %@", strResp);
            return;
        }
        
        NSArray *subTypes = [jsonData objectForKey:@"msg"];
        if (!subTypes || subTypes.count <= 0) {
            return;
        }
        
        // 请求获得新数据，更新内存
        [_officeTypeDict removeAllObjects];
        NSMutableDictionary *superTypeDic = [[NSMutableDictionary alloc] init];
        for (NSDictionary *subType in subTypes) {
            NSNumber *parentId = [NSNumber numberWithInteger:[[subType objectForKey:@"id"] integerValue]];
            NSString *parentName = [subType objectForKey:@"name"];
            [superTypeDic setObject:parentName forKey:parentId];
            
            NSArray *childTypeAry = [subType objectForKey:@"childs"];
            for (NSDictionary *childTypeDic in childTypeAry) {
                NSNumber *subTypeID = [childTypeDic objectForKey:@"id"];
                NSString *subTypeName = [childTypeDic objectForKey:@"name"];
                
                if (!subTypeID || subTypeID.integerValue <= 0 || !parentId || parentId.integerValue <= 0) {
                    NSLog(@"action=questiontypechild data invalid: %@", subType);
                    continue;
                }
                
                NSMutableDictionary *subTypeDictForOffice = [_officeTypeDict objectForKey:parentId];
                if (!subTypeDictForOffice) {
                    subTypeDictForOffice = [[NSMutableDictionary alloc] init];
                    [_officeTypeDict setObject:subTypeDictForOffice forKey:parentId];
                }
                [subTypeDictForOffice setObject:subTypeName forKey:subTypeID];
            }
        }
        _officeSuperTypeDict = [superTypeDic copy];
        // 保存本地
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_officeTypeDict];
        [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:OFFICE_SUBTYPE_DICT];
        archiveData = [NSKeyedArchiver archivedDataWithRootObject:_officeSuperTypeDict];
        [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:OFFICE_SUPERTYPE_ARRAY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
