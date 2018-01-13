//
//  DeviceSearchViewController.m
//  SZNDTCloundKitDemo
//
//  Created by JianWei Chen on 16/12/17.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "DeviceSearchViewController.h"
#import "DeviceListViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "KTActionSheet.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MJRefresh.h"

@interface DeviceSearchViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDeviceView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) NSTimer *deviceTimer;

@end

@implementation DeviceSearchViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [self deviceTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateDeviceList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_deviceTimer invalidate];
    _deviceTimer = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)updateDeviceList
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[[DTCloudManager defaultJNI_iOS_SDK]getAllDeviceInLocalAreaNetwork]];
    [self.tableView reloadData];
}

- (void)refreshBaseControlValue
{
    [self setNavigationBarTitle:@"网内设备列表"];
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self updateDeviceList];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }];
}

- (void)onLeftButtonClick:(id)sender
{
    [_deviceTimer invalidate];
    _deviceTimer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count == 0) {
        self.noDeviceView.hidden = NO;
    }else{
        self.noDeviceView.hidden = YES;
    }
    return [self.dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceSearchTableViewCell"];
    
    ((UILabel *)[cell viewWithTag:1]).text = [self.dataSource[indexPath.section]deviceName];
    
    DTDevice *device = self.dataSource[indexPath.row];
    [((UILabel *)[cell viewWithTag:1]) setText:[NSString stringWithFormat:@"mac:%@ productId:%@",device.macAddress,device.deviceTypeID]];
    
    for (DTDevice *existDevice in [[AppDelegate defaultService]deviceList]) {
        if ([existDevice.macAddress.lowercaseString isEqualToString:device.macAddress.lowercaseString]) {
            [((UILabel *)[cell viewWithTag:1]) setText:[NSString stringWithFormat:@"%@",existDevice.deviceName]];
            break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    DTDevice *device = self.dataSource[indexPath.row];
    for (DTDevice *existDevice in [[AppDelegate defaultService]deviceList]) {
        if ([existDevice.macAddress.lowercaseString isEqualToString:device.macAddress.lowercaseString]) {
            [SVProgressHUD showInfoWithStatus:@"该设备已添加"];
            return;
        }
    }

    UIAlertView  *alertView = [[UIAlertView alloc] initWithTitle:@"设备名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
    alertView.tag = indexPath.row;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DTDevice *device = self.dataSource[alertView.tag];
    if (buttonIndex == 1) {
        
        if ([alertView textFieldAtIndex:0].text.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"名字不能为空"];
            return;
        }
        if ([alertView textFieldAtIndex:0].text.length > 20) {
            [SVProgressHUD showInfoWithStatus:@"名字长度不能超过20个"];
            return;
        }
        
        if ([self isContainsTwoEmoji:[alertView textFieldAtIndex:0].text] ) {
            [SVProgressHUD showInfoWithStatus:@"名字不能使用表情"];
            return;
        }
        [[DTCloudManager defaultJNI_iOS_SDK]bindDeviceByName:[alertView textFieldAtIndex:0].text macAddress:device.macAddress.uppercaseString productId:device.deviceTypeID deviceType:DeviceUsedByWiFi successCallback:^(NSDictionary *dic) {
            [SVProgressHUD showSuccessWithStatus:dic[@"errmsg"] maskType:SVProgressHUDMaskTypeBlack];
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[DeviceListViewController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    return ;
                }
            }
        } errorCallback:^(NSDictionary *dic) {
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"] maskType:SVProgressHUDMaskTypeBlack];
        }];
    }
}

- (IBAction)searchDevice:(UIButton *)sender
{
    [self onRightButtonClick:nil];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (NSTimer *)deviceTimer
{
    if (!_deviceTimer) {
        _deviceTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(updateDeviceList) userInfo:nil repeats:YES];
        [_deviceTimer fire];
    }
    return _deviceTimer;
}

- (BOOL)isContainsTwoEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         //         NSLog(@"hs++++++++%04x",hs);
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3|| ls ==0xfe0f) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
         
     }];
    return isEomji;
}
@end
