//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "DeviceCommandViewController.h"
#import "DeviceListViewController.h"
#import "DeviceLinkWiFiViewController.h"
#import "DeviceSearchViewController.h"
#import "ScanDeviceViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "AlertViewManager.h"
#import "KTActionSheet.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MJRefresh.h"


@interface DeviceListViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDeviceView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, strong) NSTimer *deviceTimer;
@property (nonatomic, assign) BOOL canNoRefreshTabel;

- (IBAction)searchDevice:(UIButton *)sender;

@end

@implementation DeviceListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkChange:) name:NOTIFY_NET_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceStatusChange:) name:NOTIFY_ONLINESTATUS_CHANGE object:nil];
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
    [[AppDelegate defaultService]setCurrentDevice:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateDeviceList];
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
    /*
     *  获取对应账号所绑定的设备，需确保用户登录了
     */
    [[DTCloudManager defaultJNI_iOS_SDK]getAllDeviceSuccessCallback:^(NSArray *deviceList) {
        [[[AppDelegate defaultService]deviceList] removeAllObjects];
        [[[AppDelegate defaultService]deviceList] addObjectsFromArray:deviceList];
        if (self.canNoRefreshTabel == NO) {
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
    } errorCallback:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
    }];
}

- (void)refreshBaseControlValue
{
    [self setRightButtonTitle:@"添加"];
    [self setNavigationBarTitle:@"设备列表"];
    [self setLeftButtonImage:[UIImage imageNamed:@"tittle_icon_more"]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self updateDeviceList];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }];
}

- (void)onRightButtonClick:(id)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"添加设备" itemTitles:@[@"本地配网添加",@"本地搜索添加",@"扫描添加",@"GPRS添加",@"WiFi设备添加"]];
    sheet.delegate=self;
    sheet.tag = 100;
    
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        if (index == 0) {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DeviceLinkWiFiViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DeviceLinkWiFiViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (index == 1){
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DeviceSearchViewController *vc = [story instantiateViewControllerWithIdentifier:@"DeviceSearchViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (index == 2){
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ScanDeviceViewController *vc = [story instantiateViewControllerWithIdentifier:@"ScanDeviceViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (index == 3){

            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入IMEI、设备类型、名字" preferredStyle:UIAlertControllerStyleAlert];
            //增加确定按钮；
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *imei = alertController.textFields.firstObject;
                UITextField *type = [alertController.textFields objectAtIndex:1];
                UITextField *name = alertController.textFields.lastObject;
                
                if (imei.text.length != 15) {
                    [SVProgressHUD showInfoWithStatus:@"请检查IMEI"];
                    return ;
                }
                if (type.text.length != 4) {
                    [SVProgressHUD showInfoWithStatus:@"请检查设备类型"];
                    return ;
                }
                if (!(name.text.length != 0 && name.text.length <= 8)) {
                    [SVProgressHUD showInfoWithStatus:@"请输入名字，长度不大于8个字符"];
                    return ;
                }
                [[DTCloudManager defaultJNI_iOS_SDK]bindDeviceByName:name.text macAddress:imei.text productId:type.text deviceType:DeviceUsedByGPRS_MQTT successCallback:^(NSDictionary *dic) {
                    [SVProgressHUD showInfoWithStatus:@"添加成功"];
                } errorCallback:^(NSDictionary *dic) {
                    [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
                }];
            }]];
            
            //增加取消按钮；
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            //定义第一个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入IMEI";
            }];
            //定义第二个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入设备类型";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入名字";
            }];
            
            [self presentViewController:alertController animated:true completion:nil];
        }else if (index == 4){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入Mac地址、设备类型、名字" preferredStyle:UIAlertControllerStyleAlert];
            //增加确定按钮；
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *mac = alertController.textFields.firstObject;
                UITextField *type = [alertController.textFields objectAtIndex:1];
                UITextField *name = alertController.textFields.lastObject;
                
                if (mac.text.length != 12) {
                    [SVProgressHUD showInfoWithStatus:@"请检查MAC地址"];
                    return ;
                }
                if (type.text.length != 4) {
                    [SVProgressHUD showInfoWithStatus:@"请检查设备类型"];
                    return ;
                }
                if (!(name.text.length != 0 && name.text.length <= 8)) {
                    [SVProgressHUD showInfoWithStatus:@"请输入名字，长度不大于8个字符"];
                    return ;
                }
                [[DTCloudManager defaultJNI_iOS_SDK]bindDeviceByName:name.text macAddress:mac.text productId:type.text deviceType:DeviceUsedByWiFi successCallback:^(NSDictionary *dic) {
                    [SVProgressHUD showInfoWithStatus:@"添加成功"];
                } errorCallback:^(NSDictionary *dic) {
                    [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
                }];
            }]];
            
            //增加取消按钮；
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            //定义第一个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入MAC地址";
            }];
            //定义第二个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入设备类型";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入名字";
            }];
            
            [self presentViewController:alertController animated:true completion:nil];
        }
    }];
    
}

- (void)onLeftButtonClick:(id)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:nil itemTitles:@[@"注销"]];
    sheet.delegate=self;
    sheet.tag = 100;
    
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        if (index == 0) {
            /*退出云平台*/
            [[DTCloudManager defaultJNI_iOS_SDK]logout];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[AppDelegate defaultService]deviceList].count == 0) {
        self.noDeviceView.hidden = NO;
    }else{
        self.noDeviceView.hidden = YES;
    }
    return [[[AppDelegate defaultService]deviceList]count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceListTableViewCell"];
    
    ((UILabel *)[cell viewWithTag:1]).text = [[[AppDelegate defaultService]deviceList][indexPath.row]deviceName];
    
    if ([[[AppDelegate defaultService]deviceList][indexPath.row]isOnline]) {
        DTDevice *device = [[AppDelegate defaultService]deviceList][indexPath.row];
        [((UILabel *)[cell viewWithTag:1]) setText:device.deviceName];
        [((UIButton *)[cell viewWithTag:2]) setTitle:@"在线" forState:UIControlStateNormal];
        [((UIButton *)[cell viewWithTag:2]) setTitleColor:[UIColor colorWithRed:39/255.f green:198/255.f blue:89/255.f alpha:1] forState:UIControlStateNormal];
    }else{
        [((UIButton *)[cell viewWithTag:2]) setTitle:@"离线" forState:UIControlStateNormal];
        [((UIButton *)[cell viewWithTag:2]) setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
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
    if ([[[AppDelegate defaultService]deviceList][indexPath.row]isOnline] == NO) {
        [SVProgressHUD showInfoWithStatus:@"设备处于离线状态" maskType:SVProgressHUDMaskTypeBlack];
        [tableView reloadData];
        return;
    }
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceCommandViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DeviceCommandViewController"];
    vc.device = [[AppDelegate defaultService]deviceList][indexPath.row];
    [[AppDelegate defaultService]setCurrentDevice:vc.device];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView reloadData];
}

#pragma mark - 根据值返回不同数据类型的cell

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.canNoRefreshTabel = YES;
    DTDevice *device = [[AppDelegate defaultService]deviceList][indexPath.row];
    // 添加一个删除按钮
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        self.canNoRefreshTabel = NO;
        [tableView reloadData];
        
        [[DTCloudManager defaultJNI_iOS_SDK]unBindDeviceByUUID:device.deviceUUID successCallback:^(NSDictionary *dic) {
            [SVProgressHUD showInfoWithStatus:@"解绑成功" maskType:SVProgressHUDMaskTypeBlack];
            [self updateDeviceList];
        } errorCallback:^(NSDictionary *dic) {
            [SVProgressHUD showInfoWithStatus:@"解绑失败" maskType:SVProgressHUDMaskTypeBlack];
        }];
    }];
    
    [array addObject:deleteRowAction];
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        self.canNoRefreshTabel = NO;
        [tableView reloadData];
        
        UIAlertView  *alertView = [[UIAlertView alloc] initWithTitle:@"重命名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
        alertView.tag = indexPath.row;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
        
    }];
    
    topRowAction.backgroundColor = [UIColor grayColor];
    [array addObject:topRowAction];
    
    return array;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.canNoRefreshTabel) {
        self.canNoRefreshTabel = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 90) {
        
        
        return;
    }
    DTDevice *device = [[AppDelegate defaultService]deviceList][alertView.tag];
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
        [[DTCloudManager defaultJNI_iOS_SDK]renameDeviceByUUID:device.deviceUUID andDeviceName:[alertView textFieldAtIndex:0].text successCallback:^(NSDictionary *dic) {
            [SVProgressHUD showSuccessWithStatus:dic[@"errmsg"] maskType:SVProgressHUDMaskTypeBlack];
            [self updateDeviceList];
        } errorCallback:^(NSDictionary *dic) {
            [SVProgressHUD showInfoWithStatus:dic[@"errmsg"] maskType:SVProgressHUDMaskTypeBlack];
        }];
    }
}

- (void)DeviceStatusChange:(NSNotification *)notify
{
    NSDictionary *onlineDic = notify.object;
    if ([onlineDic isKindOfClass:[NSDictionary class]]) {
        
        for (DTDevice *device in [[AppDelegate defaultService]deviceList]) {
            if ([device.macAddress isEqualToString:onlineDic[@"mac"]]) {
                device.isOnline = [onlineDic[@"isonline"]boolValue];
                break;
            }
        }
    }
    
    if (self.canNoRefreshTabel == NO) {
        [self.tableView reloadData];
    }
}

- (void)networkChange:(NSNotification *)notify
{
    [self updateDeviceList];
}

- (IBAction)searchDevice:(UIButton *)sender
{
    [self onRightButtonClick:nil];
}

- (BOOL)isContainsTwoEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
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
