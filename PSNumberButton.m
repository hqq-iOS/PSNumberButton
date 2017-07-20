//
//  PSNumberButton.m
//  PointsShop
//
//  Created by heqinqin on 2017/7/18.
//  Copyright © 2017年 hhly. All rights reserved.
//

#import "PSNumberButton.h"

@interface PSNumberButton ()<UITextFieldDelegate>
{
    CGFloat _width;     // 控件自身的宽
    CGFloat _height;    // 控件自身的高
}

@property (nonatomic, strong) NSTimer *timer;

/** 减按钮*/
@property (nonatomic, strong) UIButton *decreaseButton;

/** 加按钮*/
@property (nonatomic, strong) UIButton *increaseButton;

/** 数量展示/输入框*/
@property (nonatomic, strong) UITextField *numberTextField;

@end
@implementation PSNumberButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (CGRectIsEmpty(frame)) {
            self.frame = CGRectMake(0, 0, 110, 30);
        }
        
        [self initializeConfig];
        
        [self setupUI];
    }
    return self;
}

- (void)initializeConfig {
    //初始化最小值
    self.minValue = 1;
    //初始化最大值
    self.maxValue = NSIntegerMax;
    
    self.longPressSpaceTime = 0.3;
    
    //初始化 输入框字体大小
    self.inputFieldFont = 15;
    //初始化 +  -  号大小
    self.buttonTitleFont = 15;
    self.increaseTitle = @"＋";
    
    self.decreaseTitle = @"－";
    self.borderColor = [UIColor grayColor];


}

- (void)setupUI {
    [self addSubview:self.decreaseButton];
    [self addSubview:self.increaseButton];
    [self addSubview:self.numberTextField];
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3.f;
    self.backgroundColor = [UIColor whiteColor];
}

- (UIButton *)decreaseButton {
    if (!_decreaseButton) {
        _decreaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:_buttonTitleFont];
        [_decreaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_decreaseButton addTarget:self action:@selector(touchDownNumberAction:) forControlEvents:UIControlEventTouchDown];
        [_decreaseButton addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel];
    }
    return _decreaseButton;
}

- (UIButton *)increaseButton {
    if (!_increaseButton) {
        _increaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _increaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:_buttonTitleFont];
        [_increaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_increaseButton addTarget:self action:@selector(touchUpNumberAction:) forControlEvents:UIControlEventTouchDown];
        [_increaseButton addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel];

    }
    return _increaseButton;
}

- (UITextField *)numberTextField {
    if (!_numberTextField) {
        _numberTextField = [[UITextField alloc] init];
        _numberTextField.delegate = self;
        _numberTextField.textAlignment = NSTextAlignmentCenter;
        _numberTextField.keyboardType = UIKeyboardTypeNumberPad;
        _numberTextField.font = [UIFont systemFontOfSize:_inputFieldFont];
        _numberTextField.text = [NSString stringWithFormat:@"%ld",_minValue];
    }
    return _numberTextField;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _width =  self.frame.size.width;
    _height = self.frame.size.height;
    self.numberTextField.frame = CGRectMake(_height, 0, _width - 2*_height, _height);
    self.increaseButton.frame = CGRectMake(_width - _height, 0, _height, _height);
    self.decreaseButton.frame = CGRectMake(0, 0, _height, _height);
}

//减
- (void)touchDownNumberAction:(UIButton *)button {
    [self.numberTextField resignFirstResponder];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_longPressSpaceTime target:self selector:@selector(decrease) userInfo:nil repeats:YES];
    [_timer fire];
}

//加
- (void)touchUpNumberAction:(UIButton *)button {
    [self.numberTextField resignFirstResponder];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_longPressSpaceTime target:self selector:@selector(increase) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)touchUp:(UIButton *)button {
    [self cleanTimer];
}

/// 清除定时器
- (void)cleanTimer
{
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

/// 加运算
- (void)increase
{
    NSInteger number = self.numberTextField.text.integerValue + 1;
    
    if (number <= _maxValue) {
        self.numberTextField.text = [NSString stringWithFormat:@"%ld", number];
    
        [self buttonClickCallBackWithIncreaseStatus:YES];
    }
}

/// 减运算
- (void)decrease
{
    NSInteger number = [self.numberTextField.text integerValue] - 1;
    
    if (number >= _minValue) {
        self.numberTextField.text = [NSString stringWithFormat:@"%ld", number];
        [self buttonClickCallBackWithIncreaseStatus:NO];
    }
}

/// 点击响应
- (void)buttonClickCallBackWithIncreaseStatus:(BOOL)increaseStatus
{
    _resultBlock ? _resultBlock(self.numberTextField.text.integerValue, increaseStatus) : nil;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkTextFieldNumberWithUpdate];
    [self buttonClickCallBackWithIncreaseStatus:NO];
}

/// 检查TextField中数字的合法性,并修正
- (void)checkTextFieldNumberWithUpdate
{
    NSString *minValueString = [NSString stringWithFormat:@"%ld",_minValue];
    NSString *maxValueString = [NSString stringWithFormat:@"%ld",_maxValue];
    
    if ([self.numberTextField.text isNotBlank] == NO || self.numberTextField.text.integerValue < _minValue) {
        self.numberTextField.text = minValueString;
    }
    self.numberTextField.text.integerValue > _maxValue ? self.numberTextField.text = maxValueString : nil;
}


#pragma mark -- settting
- (void)setEditing:(BOOL)editing {
    _editing = editing;
    self.numberTextField.enabled = editing;
}

- (void)setMinValue:(NSInteger)minValue {
    _minValue = minValue;
    self.numberTextField.text = [NSString stringWithFormat:@"%zd",minValue];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = _borderColor.CGColor;
    
    self.increaseButton.layer.borderWidth = 0.5;
    self.increaseButton.layer.borderColor = _borderColor.CGColor;
    
    self.decreaseButton.layer.borderWidth = 0.5;
    self.decreaseButton.layer.borderColor = _borderColor.CGColor;
    
}

- (void)setUnEnableColor:(UIColor *)unEnableColor {
    _unEnableColor = unEnableColor;
    [self.increaseButton setTitleColor:_unEnableColor forState:UIControlStateDisabled];
    [self.decreaseButton setTitleColor:_unEnableColor forState:UIControlStateDisabled];
}

- (void)setButtonTitleFont:(CGFloat)buttonTitleFont {
    _buttonTitleFont = buttonTitleFont;
    self.increaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:buttonTitleFont];
    self.decreaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:buttonTitleFont];
}

- (void)setIncreaseTitle:(NSString *)increaseTitle {
    _increaseTitle = increaseTitle;
    [self.increaseButton setTitle:_increaseTitle forState:UIControlStateNormal];
}

- (void)setDecreaseTitle:(NSString *)decreaseTitle
{
    _decreaseTitle = decreaseTitle;
    [self.decreaseButton setTitle:decreaseTitle forState:UIControlStateNormal];
}

- (void)setIncreaseImage:(UIImage *)increaseImage
{
    _increaseImage = increaseImage;
    [self.increaseButton setBackgroundImage:increaseImage forState:UIControlStateNormal];
}

- (void)setDecreaseImage:(UIImage *)decreaseImage
{
    _decreaseImage = decreaseImage;
    [self.decreaseButton setBackgroundImage:decreaseImage forState:UIControlStateNormal];
}


-(NSInteger)currentNumber {
    return [self.numberTextField.text integerValue];
}

- (void)setCurrentNumber:(NSInteger)currentNumber
{
    self.numberTextField.text = [NSString stringWithFormat:@"%ld",currentNumber];
}

- (void)setInputFieldFont:(CGFloat)inputFieldFont
{
    _inputFieldFont = inputFieldFont;
    self.numberTextField.font = [UIFont systemFontOfSize:inputFieldFont];
}

@end


#pragma mark - NSString分类
@implementation NSString (PSNumberButton)
- (BOOL)isNotBlank
{
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}
@end
