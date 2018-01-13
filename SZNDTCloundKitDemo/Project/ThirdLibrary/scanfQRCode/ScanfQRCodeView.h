//
//  ScanfQRCodeView.h
//  FamilyShow
//
//  Created by guoziyi on 15-1-19.
//  Copyright (c) 2015年 net.sunniwell.sz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ScanfQRCodeView;
@protocol ScanfQRCodeViewDelegate <NSObject>

- (void) scanfQRCode:(ScanfQRCodeView *)scanfview result:(NSString *)result;

@end

@interface ScanfQRCodeView : UIView<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<ScanfQRCodeViewDelegate> delegate;

- (void)startScan;
- (void)CancelRunning;
- (void)stopRunning;

@end
