//
//  DeviceLinkWiFiViewController.m
//  SZNDTCloundKitDemo
//
//  Created by JianWei Chen on 16/12/16.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import "DeviceSearchViewController.h"
#import "DeviceLinkWiFiViewController.h"
#import "ScanDeviceViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "KTActionSheet.h"
#import "SVProgressHUD.h"

@interface DeviceLinkWiFiViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) UITextField *deviceManufacturerTF;
@property (strong, nonatomic) UITextField *WifiNameTF;
@property (strong, nonatomic) UITextField *WifiPwdTF;
@property (strong, nonatomic) UITextField *productTypeTF;
@property (strong, nonatomic) UITextField *productNameTF;
@property (assign,nonatomic) LinkType linktype;

@end

@implementation DeviceLinkWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.WifiNameTF.text = [self getDeviceSSID];
    self.WifiPwdTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:self.WifiNameTF.text];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
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
    
    UIBarButtonItem *bar1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scan_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButtonClick:)];
    UIBarButtonItem *bar2 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"side_icon_search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchLocalDevice:)];
    self.navigationItem.rightBarButtonItems = @[bar1,bar2];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.linktype = HFLinkMan;
}

- (void)onRightButtonClick:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ScanDeviceViewController *vc = [story instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)searchLocalDevice:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceSearchViewController *vc = [story instantiateViewControllerWithIdentifier:@"DeviceSearchViewController"];
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
    [[NSUserDefaults standardUserDefaults]setValue:self.WifiPwdTF.text forKey:self.WifiNameTF.text];
    [[NSUserDefaults standardUserDefaults]setValue:self.deviceManufacturerTF.text forKey:@"配对模块"];
    [[NSUserDefaults standardUserDefaults]setValue:self.productTypeTF.text forKey:@"配对设备类型"];
    [[NSUserDefaults standardUserDefaults]setValue:self.productNameTF.text forKey:@"配对设备名字"];
    
    [[DTCloudManager defaultJNI_iOS_SDK]startDeviceMatchingNetwork:_linktype deviceProductId:self.productTypeTF.text deviceName:self.productNameTF.text wifiSSID:[self getDeviceSSID] wifiPassword:_WifiPwdTF.text successCallback:^(NSDictionary *dic) {
        
        DTDevice *device = dic[@"data"];
        [[DTCloudManager defaultJNI_iOS_SDK]bindDeviceByName:device.deviceName macAddress:device.macAddress.uppercaseString productId:device.deviceTypeID deviceType:DeviceUsedByWiFi successCallback:^(NSDictionary *dic) {
            [SVProgressHUD showSuccessWithStatus:@"配对成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } errorCallback:^(NSDictionary *dic) {
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
        }];
    } errorCallback:^(NSDictionary *dic) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:dic[@"errmsg"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [SVProgressHUD dismiss];
    }];
}

- (IBAction)NextAction:(id)sender
{
    if(_WifiPwdTF.text.length<=0){
        [SVProgressHUD showErrorWithStatus:@"请输入wifi密码"];
    }else{
        [self startSmartLink];
    }
}

- (IBAction)modleSelect:(UIButton*)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"WIFI模块选择" itemTitles:@[@"庆科",@"汉枫",@"乐鑫",@"Marvel",@"集贤6060",@"新力维6060",@"庆科AWS"]];
    sheet.delegate=self;
    sheet.tag = 100;
    __weak typeof(self) weakSelf = self;
    [self.view endEditing:YES];
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        weakSelf.linktype=index+1;
        weakSelf.deviceManufacturerTF.text = title;
    }];
}

- (IBAction)pwdSecAction:(UIButton*)sender
{
    sender.selected=!sender.selected;
    _WifiPwdTF.secureTextEntry=!sender.selected;
}

- (IBAction)goTowifi:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"LinkWiFiTableViewCell_%d%d",(int)indexPath.section,(int)indexPath.row]];
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (self.deviceManufacturerTF == nil) {
            self.deviceManufacturerTF = [cell viewWithTag:1];
            if ([[NSUserDefaults standardUserDefaults]valueForKey:@"配对模块"]) {
                self.deviceManufacturerTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"配对模块"];
                NSArray *list = @[@"庆科",@"汉枫",@"乐鑫",@"Marvel",@"集贤6060",@"新力维6060",@"庆科AWS"];
                self.linktype = [list indexOfObject:self.deviceManufacturerTF.text] + 1;
            }
        }
    }else if (indexPath.row == 1 && indexPath.section == 0){
        self.WifiNameTF = [cell viewWithTag:1];
    }else if (indexPath.row == 2 && indexPath.section == 0){
        self.WifiPwdTF = [cell viewWithTag:1];
    }else if (indexPath.row == 3 && indexPath.section == 0){
        if (self.productTypeTF == nil) {
            self.productTypeTF = [cell viewWithTag:1];
            self.productTypeTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"配对设备类型"];
        }
        
    }else if (indexPath.row == 4 && indexPath.section == 0){
        if (self.productNameTF == nil) {
            self.productNameTF = [cell viewWithTag:1];
            self.productNameTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"配对设备名字"];
        }
    }else if (indexPath.row == 0 && indexPath.section == 1){
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 50;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
@end
