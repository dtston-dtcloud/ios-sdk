//
//  ScanfQRCodeViewController.h
//  FamilyShow
//  二维码扫描，调用IOS的接口，需要系统在IOS7.0以上
//  Created by sunniwell on 14-12-23.
//  Copyright (c) 2014年 bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"

@class ScanfQRCodeViewController;

@protocol ScanfQRCodeDelegate <NSObject>

- (void) ScanfQRCode:(ScanfQRCodeViewController *)scanfview result:(NSString *)result;

@end

@interface ScanfQRCodeViewController : BaseViewController <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<ScanfQRCodeDelegate> delegate;

@end
