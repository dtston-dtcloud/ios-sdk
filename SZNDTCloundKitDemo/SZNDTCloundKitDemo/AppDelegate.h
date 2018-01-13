//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <DTCloudKit/DTCloudKit.h>
#import <UIKit/UIKit.h>

#define NOTIFY_MQTT_BACK @"notifyMQTTBack"
#define NOTIFY_WLAN_BACK_K @"notifyWLANBack"
#define NOTIFY_NET_CHANGE @"notifyNetBack"
#define NOTIFY_ONLINESTATUS_CHANGE @"notifyOnlineStatusChange"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *deviceList;
@property (strong, nonatomic) DTDevice *currentDevice;

+ (AppDelegate *)defaultService;

@end

