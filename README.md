
# 表情云 SDK接入文档
## 表情云 SDK简介
1. 为 APP 提供了完整的表情键盘及表情商店。
2. 环信官方`SDK3.1.3 ChatDemoUI3.0`版Demo已默认集成表情云 SDK，可以直接下载试用。

## 表情云 SDK介绍
表情云 SDK包含 `BQMM.framework` 和 `BQMM_EXT`，`BQMM.framework`提供表情键盘、表情商店，`BQMM_EXT`以开源方式提供，实现表情消息的展示。

## Step1. 导入SDK
将`BQMM`添加到工程中。

## Step2. 配置AppId及AppSecret

**@Class**:AppDelegate

**@Function**:- (BOOL)application:(UIApplication \*)application didFinishLaunchingWithOptions:(NSDictionary \*)launchOptions；

**@description**: appId及secret由表情云分配

```objectivec
// 初始化表情云 SDK
[[MMEmotionCentre defaultCentre] setAppId:@“your app id” secret:@“your secret”]
```


## Step3. 添加表情键盘

### 1.设置SDK代理
**@Class**:EaseChatToolbar

**@Function**:- (instancetype)initWithFrame:(CGRect)frame
horizontalPadding:(CGFloat)horizontalPadding
verticalPadding:(CGFloat)verticalPadding
inputViewMinHeight:(CGFloat)inputViewMinHeight
inputViewMaxHeight:(CGFloat)inputViewMaxHeight
type:(EMChatToolbarType)type;

```objectivec
[MMEmotionCentre defaultCentre].delegate = self;
```

### 2.添加表情键盘
**@Class**:EaseChatToolbar

**@Function**:- (void)faceButtonAction:(id)sender;

```objectivec
if (!_inputTextView.isFirstResponder) {
[_inputTextView becomeFirstResponder];
}
[[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView];
```

### 3.由表情键盘切换为普通键
**@Class**:EaseChatToolbar

**@Function**:- (void)faceButtonAction:(id)sender;

```objectivec
[[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
```

## Step4. 在App重新打开时清空session
**@Class**:AppDelegate

**@Function**:-- (void)applicationWillEnterForeground;

```objectivec
[[MMEmotionCentre defaultCentre] clearSession];
```

## Step5. 添加表情联想
**@Class**:EaseChatToolbar

**@Function**:- (void)setupSubviews;

```objectivec
[[MMEmotionCentre defaultCentre] shouldShowShotcutPopoverAboveView:self.faceButton withInput:self.inputTextView];
```

## Step6.熟悉表情消息编辑控件
SDK提供`UITextView+BQMM`作为表情编辑控件的扩展实现。

```objectivec
/**
* 用于显示图文混排的表情消息。
*/
@property(nonatomic, assign) NSString *mmText;
```

在编辑图文混排表情消息时，注意使用`textView.mmText`替换原有`textView.text`。

```objectivec
[self.delegate didSendText:textView.mmText];
```

## Step7. 实现表情发送代理方法
**@Class**:EaseChatToolbar

```objectivec
#pragma mark - *MMEmotionCentreDelegate

//点击键盘中大表情的代理
- (void)didSelectEmoji:(MMEmoji *)emoji
{
if ([self.delegate respondsToSelector:@selector(didSendMMFace:)]) {
[self.delegate didSendMMFace:emoji];
}
}

//点击联想表情的代理
- (void)didSelectTipEmoji:(MMEmoji *)emoji
{
if ([self.delegate respondsToSelector:@selector(didSendMMFace:)]) {
[self.delegate didSendMMFace:emoji];
self.inputTextView.text = @"";
}
}

//点击表情小表情键盘上发送按钮的代理
- (void)didSendWithInput:(UIResponder<UITextInput> *)input
{
if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
[self.delegate didSendText:_inputTextView.mmText];
self.inputTextView.text = @"";
[self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
}
}

//点击输入框切换表情按钮状态
- (void)tapOverlay
{
self.faceButton.selected = NO;
}
```

## step8.实现实际发送消息的方法：
**@Class**:EaseMessageViewController

```objectivec
//发送图文混排消息
- (void)sendTextMessage:(NSString *)text
{
NSString *text_ = [text stringByReplacingOccurrencesOfString:@"\a" withString:@""];
[MMTextParser localParseMMText:text_ completionHandler:^(NSArray *textImgArray) {
NSDictionary *mmExt = nil;
NSString *sendStr = @"";
for (id obj in textImgArray) {
if ([obj isKindOfClass:[MMEmoji class]]) {
MMEmoji *emoji = (MMEmoji*)obj;
if (!mmExt) {
mmExt = @{@"txt_msgType":@"emojitype",
@"msg_data":[MMTextParser extDataWithTextImageArray:textImgArray]};
}
sendStr = [sendStr stringByAppendingString:[NSString stringWithFormat:@"[%@]", emoji.emojiName]];
}
else if ([obj isKindOfClass:[NSString class]]) {
sendStr = [sendStr stringByAppendingString:obj];
}
}    [self sendTextMessage:sendStr withExt:mmExt];
}];
}

//发送单条大表情的方法

-(void)sendMMFaceMessage:(MMEmoji *)emoji
{
NSDictionary *mmExt = @{@"txt_msgType":@"facetype",
@"msg_data":[MMTextParser extDataWithEmojiCode:emoji.emojiCode]};
[self sendMMFaceMessage:emoji withExt:mmExt];
}

```

## Step9. 表情消息解析
我们将表情显示部分的代码从表情云 SDK中分离出来，方便开发者根据自己的业务实现表情图片显示逻辑，同时我们提供了`MMTextView`类，作为表情消息解析和显示的示例。

首先，SDK在`MMTextParser`中提供从字符串解析表情的方法`parseMMText`和`localParseMMText`。

**@Class** MMTextParser

```objectivec
+ (void)parseMMText:(NSString *)text completionHandler:(void(^)(NSArray *textImgArray))completionHandler;
+ (void)localParseMMText:(NSString *)text completionHandler:(void(^)(NSArray *textImgArray))completionHandler;
```

`localParseMMText`只解析本地已下载的表情。

参数`text`为需要解析的字符串，格式为`@"你好[hhd]"`方括号里是`emojiCode`。
`completionHandler`回调的参数`textImgArray`是消息中字符串和`Emoji`对象的数组，例：`@[@"你好", <Emoji*>]`。

另外，SDK提供了`MMTextParser`的开源扩展`MMTextParser+ExtData`，可以实现`textImgArray`、`text`和`extData`的互相转换。

**@Class** MMTextParser+ExtData

```objectivec
+ (NSArray *)extDataWithTextImageArray:(NSArray *)textImageArray;
+ (NSArray *)extDataWithEmojiCode:(NSString *)emojiCode;
+ (MMEmoji *)placeholderEmoji;
+ (NSString *)stringWithExtData:(NSArray *) extData;
```

[`extData`](#extData)是SDK推荐的用于解析的表情消息发送格式（在Demo中作为消息扩展`message.ext[@"msg_data"]`发送），格式是一个二维数组，内容为拆分完成的`text`和`emojiCode`，并且说明这段内容是否是一个`emojiCode`。例：

```objectivec
@[@[@"你好", @"0"], @[@"hhd", @"1"]]
```

`0`表示文本内容，`1`表示`emojiCode`。

`placeholderEmoji`方法提供以占位图显示的小表情对象，在`MMTextView`中需要显示小表情时，都先显示一个`placeholderEmoji`，对应的表情图片会自动从服务器下载。


## Step10. 表情消息显示

### 1.图文混排消息
**@Class** MMTextView

**@Function** -(void)setMmTextData:(NSArray *)extData;

### 2.大表情消息
根据表情code获取emoji对象，emoji的成员对象emojiImage即是大表情图片

**@Class** MMEmotionCentre

**@Function** - (void)fetchEmojisByType:(MMFetchType)fetchType
codes:(NSArray *)emojiCodes
completionHandler:(void (^)(NSArray *emojis))completionHandler;

## Step11. 添加表情详情页面
在点击大表情消息时添加单个表情详情页面，在详情页面可以查看和下载表情包信息。

**@Class** EaseMessageViewController

**@Function** - (void)messageCellSelected:(id<IMessageModel>)model;

```objectivec
UIViewController *emojiController = [[MMEmotionCentre defaultCentre] controllerForEmotionCode:model.message.ext[@"msg_data"][0][0]];
[self.navigationController pushViewController:emojiController animated:YES];
```

## Step12. UI定制

表情云 SDK通过`MMTheme`提供一定程度的UI定制。

创建一个`MMTheme`对象，设置相关属性， 然后[[MMEmotionCentre defaultCentre] setTheme:]即可修改商店和键盘样式。


## Step13. 设置APP UserId

开发者可以用`setUserId`方法设置App UserId，以便在后台统计时跟踪追溯单个用户的表情使用情况。
