//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//
#import "AppDelegate.h"
#import "SVProgressHUD.h"

#define DTCloudKitAppId     @"<#深智云开发者平台申请的APPID#>"
#define DTCloudKitAppKey    @"<#深智云开发者平台申请的APPKEY#>"

@interface AppDelegate ()<DTCloudOperationDelegate>

@end

@implementation AppDelegate

+ (AppDelegate *)defaultService
{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /*
     *  使用DTCloudKit 要到官网去申请账号生成对应的产品，并把产品的AppId和AppKey用于初始化
     */
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [[DTCloudManager defaultJNI_iOS_SDK]setSanBox:YES];
    [[DTCloudManager defaultJNI_iOS_SDK]setOperationDelegate:self];
    [[DTCloudManager defaultJNI_iOS_SDK]startAppId:DTCloudKitAppId appKey:DTCloudKitAppKey successCallback:nil errorCallback:nil];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 *  DtCloud收到设备的命令
 *
 *  @param data  设备命令
 *  @param macAddress 设备的标识
 */
- (void)dtCloudManagerMessageReceive:(NSData *)data macAddress:(NSString *)macAddress
{

}
/**
 *  发送到DtCloud命令失败
 *
 *  @param cmdtag 失败的命令标识
 */
- (void)dtCloudManagerMessageSendFaild:(NSUInteger)cmdtag
{

}
/**
 *  DtCloud发送的设备上线下线的回调
 *
 *  @param isonline 上线下线
 *  @param macAddress      设备的标识
 */
- (void)dtCloudManagerBackDeviceState:(BOOL)isonline macAddress:(NSString *)macAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ONLINESTATUS_CHANGE object:@{@"isonline":@(isonline),@"mac":macAddress}];
    if (self.currentDevice) {
        if ([self.currentDevice.macAddress isEqualToString:macAddress]) {
            if (isonline == NO) {
                if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
                    if (navi.viewControllers.count > 2) {
                        [navi popToViewController:navi.viewControllers[1] animated:YES];
                    }
                }
            }
        }
    }
}

/**
 *  DTCloud收到设备的命令
 *
 *  @param backCode    返回状态码
 *  @param backContent 返回内容
 *  @param macAddress  设备的标识
 */
- (void)dtCloudManagerMessageReceiveBackCode:(NSString *)backCode backContent:(NSString *)backContent macAddress:(NSString *)macAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MQTT_BACK object:@{@"backCode":backCode,@"backContent":backContent,@"mac":macAddress}];
}

- (void)dtCloudManagerUserLoginTokenHasExpired
{
    
}

- (NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList = [[NSMutableArray alloc]init];
    }
    return _deviceList;
}
@end
