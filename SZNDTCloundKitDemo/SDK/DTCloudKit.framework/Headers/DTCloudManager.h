//
//  DTCloudManager.h
//  DTClound
//
//  Created by JianWei Chen on 2017/7/7.
//  Copyright © 2017年 JianWei Chen. All rights reserved.
//
/*
 关于公有云开发，所有接口都必须用SDK的接口。other link 设置-ObjC
 第一步初设置服务器地址setServerType及回调代理（正式服务器地址地址可以通过getServerDominTypeByCountryCode：接口获取）
 第二步 初始化设置appid和appkey，对应开发平台的应用id和key,
 如果在SDK找不到要用的接口通过
 -(void)dtStartRequestUrl:(NSString*)requestUrl requestArgument:(NSDictionary *)param successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;进行开发，业务层自行封装。
 
 
  其它配网，固件升级及发送合令都走DTCloundManger里面的接口，其中产品id为开发平台上创建的对应这个应用下创建的。
 发命令分为短连接和长连接发送，确认固件是否支持长连接发送。
 配网分为根据固件分为三种（一种固件固定服务器配网，一种AP热点配网，一种固件服务器根据sdk服务器配网）。
 */
#import <Foundation/Foundation.h>
#import "DTDevice.h"
/*
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
    EasyLinkMan_AWS =7,     //庆科AWS
    BoXinBK7231     =8,     //博芯BK7231
    Realtek8711     =9,     //Realtek 8711
};


/**设备配网阶段*/
typedef enum : NSUInteger {
    DT_Stage_Information_Send       = 1,//基本信息发送成功
    DT_Stage_WiFi_Connect           = 2,//WiFi连接中
    DT_Stage_Internet_Connect       = 3,//设备云服务连接,认证完成
    DT_Stage_Success                = 4,//设备连接成功
} DTNetworkConfigStage;

/**
 使用协议类型判别

 - DTSDKProtocolTypeSecond: 使用协议类型判别
 */
typedef NS_ENUM(NSInteger,DTSDKProtocolType)
{
    DTSDKProtocolTypeSecond      =2,     //第二代协议
    DTSDKProtocolTypeThird       =3,    //第三代协议
};
/**
设置服务器区域
 
 - ServerDomainType: 服务器区域
 */
typedef NS_ENUM(NSInteger, ServerDomainType) { // 服务器域名类型
    ServerDomainTypeTest=0,            // 阿里云测式
    ServerDomainTypeNormal=1,          // 阿里云正式
    ServerDomainTypeAWS=2,             // 亚马逊美州
    ServerDomainTypeEurope=3,          // 亚马逊欧洲
    ServerDomainTypeNone=4,            // 不设置服务器
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
- (void)dtCloudManagerMessageReceiveBackCode:(NSString *)backCode backContent:(NSString *)backContent macAddress:(NSString *)macAddress from:(int)from;

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
@property(nonatomic, strong) id <DTCloudOperationDelegate> operationDelegate;

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
- (void)startAppId:(NSString *)appId appKey:(NSString *)appKey successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;

/**
 切换到沙盒环境（需设置对应app和设备所在开发环境）

 @param type 测试环境，为正式环境,
 ServerDomainTypeTest=0,            // 阿里云测式
 ServerDomainTypeNormal=1,          // 阿里云正式
 ServerDomainTypeAWS=2,             // 亚马逊美州
 ServerDomainTypeEurope=3,          // 亚马逊欧洲
 - (void)setSanBox:(BOOL)Sanbox;弃用。
*/
-(void)setServerType:(ServerDomainType)type;

/**
 根据国家区号获取服务器信息（+86）
 
 @param countryCode 国家区号
 @return ServerDomainType 对应国家的正式服务器类型，测试不用调

 */
-(ServerDomainType)getServerDominTypeByCountryCode:(NSString*)countryCode;
/**
 切换到沙盒环境（需设置对应app和设备所在开发环境）
 
 @param Sanbox  YES测试环境，NO为正式环境,默认正式

 - (void)setSanBox:(BOOL)Sanbox;弃用。最好调有-(void)setServerType:(ServerDomainType)type;
*/

- (void)setSanBox:(BOOL)Sanbox  NS_DEPRECATED_IOS(2_0, 7_0, "Use -setServerType:") __TVOS_PROHIBITED;;
/**
 
 设置登录用户的信息

 @param tokenString token
 @param uidString uid
 */
- (void)setLoginUserToken:(NSString *)tokenString uid:(NSString *)uidString;



/**
 接口自定义(sdk内没有的接口通过这个进行扩展)
 
 @param requestUrl 短地址  @"/device/get_device_bind_user"
 @param param       请求参数字典类型一一对应,不需要传公共参数及uid和token.  @{@"device_id":@"1"}
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
-(void)dtStartRequestUrl:(NSString*)requestUrl requestArgument:(NSDictionary *)param successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;



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

 @param openID 第三方的uid（要确保唯一），如果是第三方的最好是 产品名+对应的用户id，如@"DTCloudKit12345"
 @param platformType 类型，1：QQ 2：微信 3：新浪 4第三方
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
 修改密码DTCloud云平台
 
 @param Oldpassword 云平台用户旧密码
 @param Newpassword 云平台新密码(目前密码仅支持数字字母常见符号，不支持表情空格等)
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)changePasswordWithOldpassword:(NSString *)Oldpassword Newpassword:(NSString *)Newpassword successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;

/**
 
 获取用户详细信息

 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getUserInformationSuccessCallback:(void(^)(NSDictionary *dic))successCallback errorCallback:(void(^)(NSDictionary *dic))errorCallback;
/**
 设置用户详细信息
 @param param 由字典组成
 nickname 可选     string昵称
 sex      可选     int性别，1：男、2：女
 birth    可选     string出生，如：2010-09-01（yyyy-mm-dd）或者：2010-09（yyyy-mm）
 height   可选     int身高
 weight   可选     int体重
 idcard   可选     string身份证号
 realname 可选     string真实姓名
 province 可选     string省份
 city     可选     string城市
 district 可选     string区/县
 address  可选     string详细地址
 contact  可选     string联系方式
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)setUserInformationParam:(NSDictionary *)param SuccessCallback:(void(^)(NSDictionary *dic))successCallback errorCallback:(void(^)(NSDictionary *dic))errorCallback;
/**
 设置用户头像
 @param  image 头像数据
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)setUserPortraits:(NSData*)image SuccessCallback:(void(^)(NSDictionary *dic))successCallback errorCallback:(void(^)(NSDictionary *dic))errorCallback;
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
 绑定设备，有管理员直接成为普通用户，否则直接成为管理员。

 @param deviceName 设备名字
 @param macAddress 设备mac地址
 @param productId 产品类型
 @param deviceType 设备种类
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)bindDeviceByName:(NSString *)deviceName macAddress:(NSString *)macAddress productId:(NSString *)productId deviceType:(DeviceKindType)deviceType successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;


/**
 申请绑定设备，要管理员同意。
 
 @param deviceName 设备名字
 @param macAddress 设备mac地址
 @param productId 产品类型
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
-(void)applyBindDeviceByName:(NSString *)deviceName macAddress:(NSString *)macAddress productId:(NSString *)productId  successCallback:(void (^)(NSDictionary *))successCallback errorCallback:(void (^)(NSDictionary *))errorCallback;
/**
 解绑设备

 @param deviceUUID 设备UUID（云平台返回的设备）
  @param type 类型 1-管理员删除后无管理员、2-管理员删除后下一位成为管理员 3.删除后所有人设备都没有
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)unBindDeviceByUUID:(NSString *)deviceUUID type:(NSString *)type successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;
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
 控制命令发送（本地短链接）

 @param functionCode 功能码（长度为4的16进制字符串）
 @param functionCommand 控制指令
 @param macAddress 设备MAC地址
 @param type 设备种类
 @param protocolType 协议类型
 @return 0发送成功 1functionCode、functionCommand、macAddress值为空或者长度有误 2发送失败、设备不存在
 */
- (int)sendCommandByFunctionCode:(NSString *)functionCode functionCommand:(NSString *)functionCommand deviceMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType;

/**
 控制命令发送(本地长链接)
 
 @param functionCode 功能码（长度为4的16进制字符串）
 @param functionCommand 控制指令
 @param macAddress 设备MAC地址
 @param type 设备种类
 @param protocolType 协议类型
 @return 0发送成功 1functionCode、functionCommand、macAddress值为空或者长度有误 2发送失败、设备不存在
 */
- (int)sendCommandAliveByFunctionCode:(NSString *)functionCode functionCommand:(NSString *)functionCommand deviceMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType;

/**
 获取设备的状态

 @param macAddress 设备的mac
 @return 返回：2本地在线，1远程在线，0离线
 */
- (NSInteger)getDevicesState:(NSString *)macAddress;

#pragma mark - DT云平台联网模块

/**
 开始SmartLink联网配对，固件为固定服务器地址(不会自动绑定到云平台，设备绑定到云平台，调用：bindDeviceByName:macAddress:productId:deviceType:successCallback:errorCallback:)

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
 开始AP联网配对(不会自动绑定到云平台，设备绑定到云平台，调用：bindDeviceByName:macAddress:productId:deviceType:successCallback:errorCallback:)
 
 @param modleType wifi模块类型
 @param productId 产品类型
 @param deviceName 设备名字
 @param wifiSSID wifi名字
 @param wifiPassword wifi的密码
 @param successCallback 成功回调 返回设备对象 -> dic[@"data"]
 @param errorCallback 失败回调
 @param stageCallBack 配网进度
 */
- (void)startDeviceMatchingAPNetwork:(LinkType)modleType deviceProductId:(NSString *)productId deviceName:(NSString *)deviceName wifiSSID:(NSString *)wifiSSID wifiPassword:(NSString *)wifiPassword successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback stage:(void (^)(DTNetworkConfigStage stage))stageCallBack;


#pragma mark - DT云平台联网模块(新固件支持模块服务器设置)
/**
 开始SmartLink联网配，要求固件支持模块服务器设置(不会自动绑定到云平台，设备绑定到云平台，调用：bindDeviceByName:macAddress:productId:deviceType:successCallback:errorCallback:)
 
 @param modleType wifi模块类型
 @param productId 产品类型
 @param deviceName 设备名字
 @param wifiSSID wifi名字
 @param wifiPassword wifi的密码
 @param successCallback 成功回调 返回设备对象 -> dic[@"data"]
 @param errorCallback 失败回调
 */
- (void)startDeviceMatchingNetworkServeDomain:(LinkType)modleType deviceProductId:(NSString *)productId deviceName:(NSString *)deviceName wifiSSID:(NSString *)wifiSSID wifiPassword:(NSString *)wifiPassword successCallback:(void (^)(NSDictionary *dic)) successCallback errorCallback:(void (^)(NSDictionary *dic)) errorCallback;



/**
 停止配对
 */
- (void)stopMatchingNetwork;

#pragma mark - DT云平台固件升级模块

/**
 模块的固件版本 
 errcode 为 1：设备正在进行固件升级  0：固件已是最新版本 2：固件有新版本
 errms 为 结果信息  
 @param macAddress 设备地址
 @param type 设备种类
 @param protocolType 使用协议类型
 @param callback 结果回调
 */
- (void)getFirmwareVersionByMacAddress:(NSString *)macAddress deviceType:(DeviceKindType)type protocolType:(DTSDKProtocolType)protocolType resultCallback:(void (^)(NSDictionary *dic))callback;

/**
 固件升级超时时长  在调升级前要先设置一般为30秒，不同模块超时间不同
 */
- (void)updateFirmwareVersionTimeout:(NSTimeInterval)timeout;

/**
 模块的固件版本   要先设置升级超时。
 errcode 为 1：升级中 0：升级成功  2升级失败
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

/**
 根据国家区号获取服务器信息（+86）

 @param countryCode 国家区号
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
- (void)getServerInfoByCountryCode:(NSString *)countryCode successCallback:(void (^)(NSDictionary *dic))successCallback errorCallback:(void (^)(NSDictionary *dic))errorCallback;


/**
 关闭近场心跳

 @param close 心跳关闭
 */
- (void)closeDeviceNearField:(BOOL)close;
/**
 log等级设置
 
 @param level 等级设置
 */
- (void)setConfigLogLevel:(NSInteger )level;
/**
 getVersion
 
 @return version 版本号
 */
-(NSString*)getVersion;
@end
