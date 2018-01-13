//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "ScanDeviceViewController.h"
#import "LinkWifiViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "KTActionSheet.h"
#import "SVProgressHUD.h"

@interface LinkWifiViewController()

@property(nonatomic,strong)NSString *ssid;

@property (weak, nonatomic) IBOutlet UIView *failpair_view;
@property (weak, nonatomic) IBOutlet UIImageView *DeviceTypeImage;
@property (weak, nonatomic) IBOutlet UITextField *WifiName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TipTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ButtonLineConstraint;
@property (weak, nonatomic) IBOutlet UIButton *NextStatus;
@property (weak, nonatomic) IBOutlet UITextField *WifiPwd;
@property (weak, nonatomic) IBOutlet UITextField *productTypeTF;

@property(assign,nonatomic) LinkType linktype;

@end

@implementation LinkWifiViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.WifiName.text = [self getDeviceSSID];
    self.WifiPwd.text = [[NSUserDefaults standardUserDefaults]valueForKey:self.WifiName.text];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DTCloudManager defaultJNI_iOS_SDK]stopMatchingNetwork];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)refreshBaseControlValue
{
    [self setNavigationBarTitle:@"设备联网"];
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
    [self setRightButtonImage:[UIImage imageNamed:@"scan_icon"]];
    
    self.linktype = HFLinkMan;
}

- (void)onRightButtonClick:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScanDeviceViewController *vc = [story instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSString *) getDeviceSSID
{
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease(CNCopyCurrentNetworkInfo(( CFStringRef)CFBridgingRetain(ifnam)));
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"] ;
    return ssid;
}

- (void)startSmartLink
{
    /*
     *  联网配网，需确保用户登录过了
     */
    [SVProgressHUD showWithStatus:@"联网配对中"];
    
    [[DTCloudManager defaultJNI_iOS_SDK]startDeviceMatchingNetwork:_linktype deviceProductId:self.productTypeTF.text deviceName:@"设备" wifiSSID:[self getDeviceSSID] wifiPassword:_WifiPwd.text successCallback:^(NSDictionary *dic) {
        [[NSUserDefaults standardUserDefaults]setValue:self.WifiPwd.text forKey:self.WifiName.text];
        [SVProgressHUD showSuccessWithStatus:@"配对成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } errorCallback:^(NSDictionary *dic) {
        [SVProgressHUD showErrorWithStatus:@"配对失败"];
    }];
}

- (IBAction)NextAction:(id)sender
{
    if(_WifiPwd.text.length<=0){
        [SVProgressHUD showErrorWithStatus:@"请输入wifi密码"];
    }else{
        [self startSmartLink];
    }
}
- (IBAction)GoTowifi:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (IBAction)ModleSelect:(UIButton*)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"WIFI模块选择" itemTitles:@[@"庆科",@"汉枫",@"乐鑫",@"Marvel"]];
    sheet.delegate=self;
    sheet.tag = 100;
    __weak typeof(self) weakSelf = self;
    [self.view endEditing:YES];
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        weakSelf.linktype=index+1;
        [sender setTitle:title forState:UIControlStateNormal];
    }];
}

- (IBAction)SolutionsAction:(id)sender
{
    
}

- (IBAction)PwdSecAction:(UIButton*)sender
{
    sender.selected=!sender.selected;
    _WifiPwd.secureTextEntry=!sender.selected;
}

@end
