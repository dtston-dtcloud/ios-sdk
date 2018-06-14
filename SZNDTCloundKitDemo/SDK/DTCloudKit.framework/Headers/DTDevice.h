//  DTClound
//
//  Created by JianWei Chen on 2017/7/10.
//  Copyright © 2017年 JianWei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 设备种类

 - DeviceUsedByWiFi: 设备种类
 */
typedef NS_ENUM(NSInteger,DeviceKindType)
{
    DeviceUsedByWiFi        =1,     //WiFi设备
    DeviceUsedByBlue        =2,     //蓝牙设备
    DeviceUsedByGPRS_MQTT   =3,     //GPRS设备(MQTT服务器）
    DeviceUsedByGPRS_TCP    =4,     //GPRS设备(TCP服务器)
    DeviceUsedByAPPLY  =5,     //申请绑定设备（申要管理员同意）
};

@interface DTDevice : NSObject

/**
 设备名
 */
@property (nonatomic, copy)   NSString *deviceName;

/**
 设备MAC地址
 */
@property (nonatomic, copy) NSString *macAddress;

/**
 设备Id
 */
@property (nonatomic, copy) NSString *deviceId;

/**
 设备的数据Id
 */
@property (nonatomic, copy) NSString *deviceUUID;

/**
 设备类型
 */
@property (nonatomic, copy) NSString *deviceTypeID;

/**
 设备图片
 */
@property (nonatomic, copy)   NSString *imageName;

/**
 设备连接类型
 */
@property (nonatomic,assign) DeviceKindType connect_type;

/**
 设备在线状态
 */
@property (nonatomic, assign) BOOL isOnline;

/**
 设备开关状态
 */
@property (nonatomic,assign) BOOL switchState;

@end
