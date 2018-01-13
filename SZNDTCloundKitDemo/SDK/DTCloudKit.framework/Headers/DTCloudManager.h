//
//  DTCloudManager.h
//  DTClound
//
//  Created by JianWei Chen on 2017/7/7.
//  Copyright © 2017年 JianWei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTDevice.h"

/**
 WiFi 模块类型

 - EasyLinkMan: WiFi 模块类型
 */
typedef NS_ENUM(NSInteger,LinkType)
{
    EasyLinkMan     =1,     //庆科
    HFLinkMan       =2,     //汉枫
    LXLinkMan       =3,     //乐鑫
    MarvellLinkMan  =4,     //Marvell
    JiXian6060      =5,     //集贤6060
    XinLiWei6060    =6,     //新力维6060
    EasyLinkMan_AWS =7,     //·
};


/**
 使用协议类型判别

 - DTSDKProtocolTypeSecond: 使用协议类型判别
 */
typedef NS_ENUM(NSInteger,DTSDKProtocolType)
{
    DTSDKProtocolTypeSecond      =2,     //第二代协议
    DTSDKProtocolTypeThird       =3,    //第三代协议
};

@protocol DTCloudOperationDelegate <NSObject>

@required
/**
 *  DTCloud收到设备的命令
 *
 *  @param backCode    返回状态码
 *  @param backContent 返回内容
 *  @param macAddress  设备的标识
 */
- (void)dtCloudManagerMessageReceiveBackCode:(NSString *)backCode backContent:(NSString *)backContent macAddress:(NSString *)macAddress;

/**
 *  发送到DTCloud命令失败
 *
 *  @param cmdtag 失败的命令标识
 */
- (void)dtCloudManagerMessageSendFaild:(NSUInteger)cmdtag;

/**
 *  DTCloud发送的设备上线下线的回调
 *
 *  @param isonline     上线下线
 *  @param macAddress   设备的标识
 */
- (void)dtCloudManagerBackDeviceState:(BOOL)isonline macAddress:(NSString *)macAddress;

/**
 *  DTCloud用户登录凭证过期回调，需重新登录
 */
- (void)dtCloudManagerUserLoginTokenHasExpired;

@end


@interface DTCloudManager : NSObject

/*云平台SDK返回设备数据和设备状态*/
@property(nonatomic, weak) id <DTCloudOperationDelegate> operationDelegate;

#pragma mark - 云平台初始化

/**
 云平台SDK

 @return 云平台SDK
 */
+ (DTCloudManager *)defaultJNI_iOS_SDK;

/**
 初始化DTCloud

 @param appId 通过前台申请的appId
 @param appKey 通过前台申请的appKey
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)startAppId:(NSString *)appId appKey:(NSString *)appKey successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;;

/**
 切换到沙盒环境（需设置对应app和设备所在开发环境）

 @param Sanbox 是否为沙盒（NO为正式环境，YES为测试环境，默认为正式环境）
 */
- (void)setSanBox:(BOOL)Sanbox;


/**
 设置登录用户的信息

 @param tokenString token
 @param uidString uid
 */
- (void)setLoginUserToken:(NSString *)tokenString uid:(NSString *)uidString;
/**
 登录DTCloud云平台（需登录，才能获取对应用户的设备信息）

 @param username 云平台用户(目前限定：手机号码)
 @param password 云平台密码
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 第三方登录

 @param openID 第三方的uid（要确保唯一）
 @param platformType 类型，1：QQ 2：微信 3：新浪
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)loginWithThirdOpenId:(NSString *)openID type:(int)platformType successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 退出云平台（当退出平台以后，再次使用平台需登录）
 */
- (void)logout;

#pragma mark - DTCloud云平台用户模块

/**
 获取DTCloud云平台注册验证码

 @param username 注册的用户名(目前限定：手机号码)
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getRegisterCodeWithUsername:(NSString *)username successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 注册DTCloud云平台

 @param username 云平台用户(目前限定：手机号码)
 @param password 云平台密码(目前密码仅支持数字字母常见符号，不支持表情空格等)
 @param vcode 云平台注册验证码
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)registerWithUsername:(NSString *)username password:(NSString *)password securityCode:(NSString *)vcode successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 获取DTCloud云平台忘记密码的验证码

 @param username 注册的用户名(目前限定：手机号码)
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getForgetPasswordCodeWithUsername:(NSString *)username successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 重置密码DTCloud云平台

 @param username 云平台用户(目前限定：手机号码)
 @param password 云平台密码(目前密码仅支持数字字母常见符号，不支持表情空格等)
 @param vcode 云平台验证码
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)resetPasswordWithUsername:(NSString *)username password:(NSString *)password securityCode:(NSString *)vcode successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 获取用户详细信息

 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getUserInformationSuccessCallback:(void(^)(NSDictionary *dic))successCallback errorCallback:(void(^)(NSDictionary *dic))errorCallback;

#pragma mark - DT云平台设备模块

/**
 获取DTCloud上的所有设备

 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getAllDeviceSuccessCallback:(void (^)(NSArray *deviceList))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 获取局域网内的所有设备

 @return 获取局域网内的所有设备
 */
- (NSArray *)getAllDeviceInLocalAreaNetwork;

/**
 绑定设备

 @param deviceName 设备名字
 @param macAddress 设备mac地址
 @param productId 产品类型
 @param deviceType 设备种类
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)bindDeviceByName:(NSString *)deviceName macAddress:(NSString *)macAddress productId:(NSString *)productId deviceType:(DeviceKindType)deviceType successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 解绑设备

 @param deviceUUID 设备UUID（云平台返回的设备）
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)unBindDeviceByUUID:(NSString *)deviceUUID successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 分享设备

 @param deviceUUID 设备UUID（云平台返回的设备）
 @param username 被分享用户账号
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)shareBindDeviceByUUID:(NSString *)deviceUUID username:(NSString *)username successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 重命名设备

 @param deviceUUID 设备UUID（云平台返回的设备)
 @param rename 新名称(目前密码仅支持数字字母常见符号，不支持表情空格等)
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)renameDeviceByUUID:(NSString *)deviceUUID andDeviceName:(NSString *)rename successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 修改设备的图片

 @param deviceUUID 设备UUID（云平台返回的设备)
 @param data 图片的数据
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)modifyBindDevImageByUUID:(NSString *)deviceUUID andImagedata:(NSData *)data successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

#pragma mark - DT云平台控制模块

/**
 控制命令发送

 @param functionCode 功能码（长度为4的16进制字符串）
 @param functionCommand 控制指令
 @param macAddress 设备MAC地址
 @param type 设备种类
 @param protocolType 协议类型
 @return 0发送成功 1functionCode、functionCommand、macAddress值为空或者长度有误 2发送失败、设备不存在
 */
- (int)sendCommandByFunctionCode:(NSString *)functionCode functionCommand:(NSString *)functionCommand deviceMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType;

/**
 获取设备的状态

 @param macAddress 设备的mac
 @return 返回：2本地在线，1远程在线，0离线
 */
- (int)getDevicesState:(NSString *)macAddress;

#pragma mark - DT云平台联网模块

/**
 开始联网配对(不会自动绑定到云平台，设备绑定到云平台，调用：bindDeviceByName:macAddress:productId:deviceType:successCallback:errorCallback:)

 @param modleType wifi模块类型
 @param productId 产品类型
 @param deviceName 设备名字
 @param wifiSSID wifi名字
 @param wifiPassword wifi的密码
 @param successCallback 成功回调 返回设备对象 -> dic[@"data"]
 @param errorCallback 失败回调
 */
- (void)startDeviceMatchingNetwork:(LinkType)modleType deviceProductId:(NSString *)productId deviceName:(NSString *)deviceName wifiSSID:(NSString *)wifiSSID wifiPassword:(NSString *)wifiPassword successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 停止配对
 */
- (void)stopMatchingNetwork;

#pragma mark - DT云平台固件升级模块

/**
 模块的固件版本 
 errcode 为 1：设备正在进行固件升级  2：固件已是最新版本 0：固件有新版本
 errms 为 结果信息
 @param macAddress 设备地址
 @param type 设备种类
 @param protocolType 使用协议类型
 @param callback 结果回调
 */
- (void)getFirmwareVersionByMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType resultCallback:(void (^)(NSDictionary *dic))callback;

/**
 模块的固件版本
 errcode 为 1：升级失败 0：升级成功
 errms 为 结果信息

 @param macAddress 设备地址
 @param type 设备种类
 @param protocolType 使用协议类型
 @param callback 结果回调
 */
- (void)updateFirmwareVersionByMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType resultCallback:(void (^)(NSDictionary *dic))callback;
#pragma mark - 云平台初始化兼容老应用
/**
 同步时间
 */
- (void)syncTime;

/**
 设置自己的服务器
 
 @param urlString 设置自己的服务器
 */
- (void)setServerURL:(NSString *)urlString;

/**
 设置自己的推送服务器
 
 @param urlString 设置自己的推送服务器
 */
- (void)setMQTTURL:(NSString *)urlString;

/**
 设置厂商信息
 */
- (void)setCustomerInfomationEnterpriseId:(NSString *)enterpriseIdString enterprisePid:(NSString *)enterprisePidString;

/**
 初始化DTCloud（老应用）

 @param appId 通过前台申请的appId
 @param appKey 通过前台申请的appKey
 @param appSecrect 通过前台申请的appSecrect
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)startAppId:(NSString *)appId appKey:(NSString *)appKey appSecrect:(NSString *)appSecrect successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 添加本地监听设备
 
 @param macAddress 设备mac地址
 @param status 设备状态
 */
- (void)addDeviceInServerForMonitor:(NSString *)macAddress andOnlineStatus:(BOOL)status;
@end
