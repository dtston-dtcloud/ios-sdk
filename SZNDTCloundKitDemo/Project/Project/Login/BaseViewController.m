//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "BaseViewController.h"

#define SystemVersionIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)

#ifdef SystemVersionIOS7
#define BASE_TEXTSIZE(text, font) ([text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero)
#else
#define BASE_TEXTSIZE(text, font) ([text length] > 0 ? [text sizeWithFont:font] : CGSizeZero)
#endif

@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar"] forBarMetrics:UIBarMetricsDefault];
    
    [self stopGestureInit];
    [self refreshBaseControlValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self refreshInformation];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    [self touchView:touch.view];
    return  YES;
}

- (void)touchView:(UIView *)touchView
{
    
}

- (void)stopGestureInit
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(stopEditing)];
    gestureRecognizer.delegate = self;
    [gestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)stopEditing
{
    [self.view endEditing:YES];
}

- (void)refreshBaseControlValue
{
    
}

- (void)refreshInformation
{
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self motionEndEvent];
}

- (void)motionEndEvent
{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)setLeftButtonTitle:(NSString *)title
{
    if (!_leftButton) {
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_leftButton setExclusiveTouch:YES];
        [_leftButton setTitle:title forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(onLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, _leftButton.titleLabel.font).width, BASE_TEXTSIZE(title, _leftButton.titleLabel.font).height)];
        
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_leftButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
        
        return;
    }else{
        [_leftButton setTitle:title forState:UIControlStateNormal];
        [_leftButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, _leftButton.titleLabel.font).width, BASE_TEXTSIZE(title, _leftButton.titleLabel.font).height)];
    }
}

- (void)setLeftButtonImage:(UIImage *)image
{
    if (!_leftButton) {
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_leftButton setExclusiveTouch:YES];
        [_leftButton setBackgroundImage:image forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(onLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
        
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_leftButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
        
        return;
    }else{
        [_leftButton setBackgroundImage:image forState:UIControlStateNormal];
        [_leftButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
    }
}


- (void)setNavigationBarTitle:(NSString *)title
{
    self.navigationItem.title = title;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
}


#pragma mark - 设置右按钮文字
- (void)setRightButtonTitle:(NSString *)title
{
    if (!_rightButton) {
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_rightButton setExclusiveTouch:YES];
        [_rightButton setTitle:title forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(onRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, _rightButton.titleLabel.font).width, BASE_TEXTSIZE(title, _rightButton.titleLabel.font).height)];
        
        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_rightButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        
        return;
    }else{
        [_rightButton setTitle:title forState:UIControlStateNormal];
        [_rightButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, _rightButton.titleLabel.font).width, BASE_TEXTSIZE(title, _rightButton.titleLabel.font).height)];
    }
}

- (void)setRightButtonImage:(UIImage *)image
{
    if (!_rightButton) {
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_rightButton setExclusiveTouch:YES];
        [_rightButton setBackgroundImage:image forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(onRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
        
        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_rightButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        
        return;
    }else{
        [_rightButton setBackgroundImage:image forState:UIControlStateNormal];
        [_rightButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
    }
}

#pragma mark - 左按钮按下会调用到这个函数
- (void)onLeftButtonClick:(id)sender
{
    if ([self.navigationController.visibleViewController isMemberOfClass:[UITabBarController class]]) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 右按钮按下会调用到这个函数
- (void)onRightButtonClick:(id)sender
{
    
}
- (UIImageView *)addBgImageWithFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    if (frame.size.height > 50.f) {
        [imageView setImage:[UIImage imageNamed:@"zb_001_1.png"]];
    }else{
        [imageView setImage:[UIImage imageNamed:@"main_btn_nor.png"]];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    imageView.tag=1000;
    return imageView;
}

- (UILabel *) addTitleLabelWithFrame:(CGRect)frame andText:(NSString*)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setText:text];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont systemFontOfSize:15]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:label];
    return label;
    
}

- (UITextField *) addTextFieldWithFrame:(CGRect)frame andPlaceholder:(NSString*)placeholder
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setFont:[UIFont systemFontOfSize:15]];
    textField.textColor = [UIColor blackColor];
    textField.delegate = self;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.placeholder = placeholder;
    
    [self.view addSubview:textField];
    return textField;
}

-(void)dealloc
{
    NSLog(@"dealloc======%@",NSStringFromClass([self class]));
}
@end
