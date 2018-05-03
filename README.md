# 说明：
- 本Demo使用的是 版本号为3.1.4环信官方Demo
- 下载Demo后解压根目录下的`HyphenateFullSDK.zip`
- 将appDelegate中[[MMEmotionCentre defaultCentre] setAppId:@“your app id” secret:@“your secret”]设置成分配到的`id`和`secret`。
- 本Demo在环信Demo的基础上集成了BQMM2.1,在修改的地方我们都加上了“BQMM集成"的注释，可在项目中全局搜索查看。

# 表情云SDK接入文档

接入**SDK**，有以下必要步骤：

1. 下载与安装
2. 获取必要的接入信息  
3. 开始集成  

##第一步：下载与安装

目前有两种方式安装SDK：

* 通过`CocoaPods`管理依赖。
* 手动导入`SDK`并管理依赖。

###1. 使用 CocoaPods 导入SDK

在终端中运行以下命令：

```
pod search BQMM
```

如果运行以上命令，没有搜到SDK，或者搜不到最新的 SDK 版本，您可以运行以下命令，更新您本地的 CocoaPods 源列表。

```
pod repo update
```

在您工程的 Podfile中添加最新版本的SDK（在此以2.1版本为例）：

```
pod 'BQMM', '2.1'
```

然后在工程的根目录下运行以下命令：

```
pod install
```

说明：pod中不包含gif表情的UI模块，可在官网[下载](http://7xl6jm.com2.z0.glb.qiniucdn.com/release/android-sdk/BQMM_Lib_V2.0.zip)，手动导入`BQMM_GIF`


###2. 手动导入SDK

下载当前最新版本，解压缩后获得3个文件夹

* `BQMM`
* `BQMM_EXT`
* `BQMM_GIF`

`BQMM`中包含SDK所需的资源文件`BQMM.bundle`和库文件`BQMM.framework`;`BQMM_EXT`提供了SDK的默认消息显示控件和消息默认格式的开源代码，开发者们导入后可按需修改;`BQMM_GIF`中包含gif表情的UI模块，开发者导入后可按需修改。

###3. 添加系统库依赖

您除了在工程中导入 SDK 之外，还需要添加libz动态链接库。


##第二步：获取必要的接入信息

开发者将应用与SDK进行对接时,必要接入信息如下

* `appId` - 应用的App ID
* `appSecret` - 应用的App Secret


如您暂未获得以上接入信息，可以在此[申请](http://open.biaoqingmm.com/open/register/index.html)


##第三步：开始集成

###0. 注册AppId&AppSecret、设置SDK语言和区域

在 `AppDelegate` 的 `-application:didFinishLaunchingWithOptions:` 中添加：

```objectivec
// 初始化SDK
[[MMEmotionCentre defaultCentre] setAppId:@“your app id” secret:@“your secret”]

//设置SDK语言和区域
[MMEmotionCentre defaultCentre].sdkLanguage = MMLanguageEnglish;
[MMEmotionCentre defaultCentre].sdkRegion = MMRegionChina;

```

###1. 在App重新打开时清空session

在 `AppDelegate` 的 `- (void)applicationWillEnterForeground:` 中添加：

```objectivec
[[MMEmotionCentre defaultCentre] clearSession];
```

###2. 使用表情键盘和GIF搜索模块

####设置SDK代理 

`EaseChatToolbar.m`
```objectivec
- (instancetype)initWithFrame:(CGRect)frame {
    ....
    //BQMM集成
    [MMEmotionCentre defaultCentre].delegate = self;
    ....
}
```

####配置GIF搜索模块

`EaseMessageViewController.m`
```objectivec
- (void)viewDidLoad {
    ....
    //BQMM集成   设置gif搜索相关
    [[MMGifManager defaultManager] setSearchModeEnabled:true withInputView:_inputToolBar.inputTextView];
    [[MMGifManager defaultManager] setSearchUiVisible:true withAttatchedView:_inputToolBar];
        
    __weak typeof(self) weakSelf = self;
    [MMGifManager defaultManager].selectedHandler = ^(MMGif * _Nullable gif) {
        __strong MMChatViewController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf didSendGifMessage:gif];
        }
    };
    ....
}

-(void)didSendGifMessage:(MMGif *)gif {
    NSString *sendStr = [@"[" stringByAppendingFormat:@"%@]", gif.text];
    NSDictionary *msgData = @{WEBSTICKER_URL: gif.mainImage, WEBSTICKER_IS_GIF: (gif.isAnimated ? @"1" : @"0"), WEBSTICKER_ID: gif.imageId,WEBSTICKER_WIDTH: @((float)gif.size.width), WEBSTICKER_HEIGHT: @((float)gif.size.height)};
    NSDictionary *extDic = @{TEXT_MESG_TYPE:TEXT_MESG_WEB_TYPE,
                             TEXT_MESG_DATA:msgData
                             };
    
    EMMessage *message = [EaseSDKHelper sendTextMessage:sendStr
                                                     to:self.conversation.conversationId
                                            messageType:[self _messageTypeFromConversationType]
                                             messageExt:extDic];
    [self _sendMessage:message];
}
```

####实现SDK代理方法

`EaseChatToolbar.m` 实现了SDK的代理方法

```objectivec
//点击键盘中大表情的代理
- (void)didSelectEmoji:(MMEmoji *)emoji
{
    if ([self.delegate respondsToSelector:@selector(didSendMMFace:)]) {
        [self.delegate didSendMMFace:emoji];
    }
}

//点击联想表情的代理 （`deprecated`）
- (void)didSelectTipEmoji:(MMEmoji *)emoji
{
    if ([self.delegate respondsToSelector:@selector(didSendMMFace:)]) {
        [self.delegate didSendMMFace:emoji];
        self.inputTextView.text = @"";
    }
}

//点击小表情键盘上发送按钮的代理
- (void)didSendWithInput:(UIResponder<UITextInput> *)input
{
    if ([input isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)input;
        NSString *sendStr = textView.characterMMText;
        sendStr = [sendStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![sendStr isEqualToString:@""]) {
            if ([self.delegate respondsToSelector:@selector(didSendTextMessageWithTextView:)]) {
                [self.delegate didSendTextMessageWithTextView:textView];
                self.inputTextView.text = @"";
                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:_inputTextView]];
            }
        }
    }
}

//点击输入框切换表情按钮状态
- (void)tapOverlay
{
    self.faceButton.selected = NO;
}

```

`EaseChatToolbar` 通过代理将发送大表情及点击gif按钮代理给`EaseMessageViewController`
```objectivec
//BQMM集成

/**
 *  点击Gif tab
 */
- (void)didClickGifTab;

/**
 *  发送表情MM大表情
 *
 *  @param emoji 表情对象
 */
- (void)didSendMMFace:(MMEmoji *)emoji;

/**
 *  发送表情MM大表情
 *
 *  @param emoji 表情对象
 *  @param ext 扩展消息
 */
- (void)didSendMMFace:(MMEmoji *)emoji withExt:(NSDictionary*)ext;
```

`EaseMessageViewController`
```objectivec
//点击键盘中的gif按钮
- (void)didClickGifTab {
    //点击gif tab 后应该保证搜索模式是打开的 搜索UI是允许显示的
    [[MMGifManager defaultManager] setSearchModeEnabled:true withInputView:((EaseChatToolbar *)self.chatToolbar).inputTextView];
    [[MMGifManager defaultManager] setSearchUiVisible:true withAttatchedView:self.chatToolbar];
    [[MMGifManager defaultManager] showTrending];
}
```

####表情键盘和普通键盘的切换

`EaseChatToolbar`

```objectivec
- (void)faceButtonAction:(id)sender
{
    ...
    //BQMM集成
    if (button.selected) {
        self.moreButton.selected = NO;
        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView];
        if (!_inputTextView.isFirstResponder) {
            [_inputTextView becomeFirstResponder];
        }
        self.faceButton.selected = YES;
    }
    else {
    	//切换成普通键盘
        [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    }
    ...
}
```


###3. 使用表情消息编辑控件
SDK提供`UITextView+BQMM`作为表情编辑控件的扩展实现，可以以图文混排方式编辑，并提取编辑内容。
消息编辑框需要使用此控件，在适当位置引入头文件 

```objectivec
#import <BQMM/BQMM.h>
```

###4.消息的编码及发送

表情相关的消息需要编码成`extData`放入IM的普通文字消息的扩展字段，发送到接收方进行解析。
`extData`是SDK推荐的用于解析的表情消息发送格式，格式是一个二维数组，内容为拆分完成的`text`和`emojiCode`，并且说明这段内容是否是一个`emojiCode`。

#####图文混排消息
`EaseChatToolbar`
```objectivec
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            //BQMM集成
            NSString *sendStr = self.inputTextView.characterMMText;
            sendStr = [sendStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (![sendStr isEqualToString:@""]) {
                if ([self.delegate respondsToSelector:@selector(didSendTextMessageWithTextView:)]) {
                    [self.delegate didSendTextMessageWithTextView:self.inputTextView];
                }
            }

            self.inputTextView.text = @"";
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    ...
}
```

`EaseMessageViewController`
```objectivec
- (void)didSendTextMessageWithTextView:(UITextView *)textView {
    NSString *sendStr = textView.characterMMText;
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    ...
    NSArray *textImgArray = textView.textImgArray;
    NSDictionary *mmExt = @{TEXT_MESG_TYPE:TEXT_MESG_EMOJI_TYPE,
                            TEXT_MESG_DATA:[MMTextParser extDataWithTextImageArray:textImgArray]};;
    [ext addEntriesFromDictionary:mmExt];
    [self sendTextMessage:sendStr withExt:ext];
}

```

#####大表情消息

`EaseMessageViewController`
```objectivec
-(void)sendMMFaceMessage:(MMEmoji *)emoji
{
    NSDictionary *mmExt = @{TEXT_MESG_TYPE:TEXT_MESG_FACE_TYPE,
                            TEXT_MESG_DATA:[MMTextParser extDataWithEmoji:emoji]};
    [self sendMMFaceMessage:emoji withExt:mmExt];
}
```

#####Gif表情消息

`EaseMessageViewController`
```objectivec
-(void)didSendGifMessage:(MMGif *)gif {
    NSString *sendStr = [@"[" stringByAppendingFormat:@"%@]", gif.text];
    NSDictionary *msgData = @{WEBSTICKER_URL: gif.mainImage, WEBSTICKER_IS_GIF: (gif.isAnimated ? @"1" : @"0"), WEBSTICKER_ID: gif.imageId,WEBSTICKER_WIDTH: @((float)gif.size.width), WEBSTICKER_HEIGHT: @((float)gif.size.height)};
    NSDictionary *extDic = @{TEXT_MESG_TYPE:TEXT_MESG_WEB_TYPE,
                             TEXT_MESG_DATA:msgData
                             };
    
    EMMessage *message = [EaseSDKHelper sendTextMessage:sendStr
                                                     to:self.conversation.conversationId
                                            messageType:[self _messageTypeFromConversationType]
                                             messageExt:extDic];
    [self _sendMessage:message];
}
```

Gif表情消息扩展解析出的图片尺寸存储在gifSize中，用于显示时布局。
`EaseMessageModel` 、 `IMessageModel`
```objectivec
@property (nonatomic) CGSize gifSize;
```

###5. 表情消息的解析

消息的扩展解析
`EaseMessageModel` 、`IMessageModel`
```objectivec
//存储消息的扩展
@property (strong, nonatomic) NSDictionary *mmExt;
@property (nonatomic) CGSize gifSize;
```

`EaseMessageModel`
```objectivec
- (instancetype)initWithMessage:(EMMessage *)message
{
    self = [super init];
    if (self) {
        ...
        //BQMM集成
        NSDictionary *ext = message.ext;
        self.mmExt = ext;
        CGSize size = CGSizeZero;
        if([ext[TEXT_MESG_TYPE] isEqualToString: TEXT_MESG_WEB_TYPE]) {
            NSDictionary *msgData = ext[TEXT_MESG_DATA];
            float height = [msgData[WEBSTICKER_HEIGHT] floatValue];
            float width = [msgData[WEBSTICKER_WIDTH] floatValue];
            //宽最大200 高最大 150
            if (width > 200) {
                height = 200.0 / width * height;
                width = 200;
            }else if(height > 150) {
                width = 150.0 / height * width;
                height = 150;
            }
            size = CGSizeMake(width, height);
        }
        self.gifSize = size;
    }
}
```

#### 混排消息的解析
从消息的扩展中解析出`extData`
```objectivec
NSDictionary *extDic = messageModel.ext;
if (extDic != nil && [extDic[@"txt_msgType"] isEqualToString:@"emojitype"]) {
    NSArray *extData = extDic[@"msg_data"];
}
```

#### 单个大表情解析

从消息的扩展中解析出大表情（MMEmoji）的emojiCode

`EaseCustomMessageCell`
```objectivec
- (void)setCustomModel:(id<IMessageModel>)model
{
	...
	else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
		...
		NSString *emojiCode = nil;
        if (model.mmExt[TEXT_MESG_DATA]) {
            emojiCode = model.mmExt[TEXT_MESG_DATA][0][0];
        }
        ...
	}
	...
}
```

#### Gif表情解析

从消息的扩展中解析出Gif表情（MMGif）的imageId和mainImage

`EaseCustomMessageCell`
```objectivec
- (void)setCustomModel:(id<IMessageModel>)model
{
	...
	else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
		...
		NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];
        NSString *webStickerUrl = msgData[WEBSTICKER_URL];
        NSString *webStickerId = msgData[WEBSTICKER_ID];
        ...
	}
	...
}
```


###6. 表情消息显示

#### 混排消息
SDK提供`MMTextView`作为显示图文混排表情消息的展示, Demo中添加了`EMBubbleView+MMText`扩展便于布局。
初始化：
`EMBubbleView+MMText`
```objectivec
- (void)setupMMTextBubbleViewWithModel:(id<IMessageModel>)model
{
    ...
    self.textView = [[MMTextView alloc] init];
    self.textView.mmFont = [UIFont systemFontOfSize:15];
    self.textView.mmTextColor = [UIColor blackColor];
    ...
}  
```

设置数据：
`EaseCustomMessageCell`
```objectivec
- (void)setCustomModel:(id<IMessageModel>)model
{
    if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        [_bubbleView.textView setMmTextData:model.mmExt[TEXT_MESG_DATA]];
    }
    ...
}
```

布局：
`EaseCustomMessageCell`
```objectivec
- (void)layoutSubviews
{
    ...
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            //BQMM集成
            if ([self.model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
                CGFloat bubbleMaxWidth = self.bubbleMaxWidth;
                if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
                    bubbleMaxWidth = 200;
                }
                bubbleMaxWidth -= (self.leftBubbleMargin.left + self.leftBubbleMargin.right + self.rightBubbleMargin.left + self.rightBubbleMargin.right)/2;
                CGSize size = [MMTextParser sizeForMMTextWithExtData:self.model.mmExt[TEXT_MESG_DATA] font:self.messageTextFont maximumTextWidth:bubbleMaxWidth];
                [self setBubbleWidth:size.width + 25];
            }
            ...
        }
    }
    ...
}
```

复制消息内容：
`EaseMessageViewController`
```objectivec
- (void)copyMenuAction:(id)sender
{
    //BQMM集成
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
            pasteboard.string = [MMTextParser stringWithExtData:model.mmExt[TEXT_MESG_DATA]];
        }
        else {
            pasteboard.string = model.text;
        }
    }
    
    self.menuIndexPath = nil;
}
```

另外，开发者可参照`MMTextView`中的`updateAttributeTextWithData:completionHandler:`方法定义自己的表情消息显示方式。参数<a name="extData">`extData`</a>是拆分过的文本和`emojiCode`。


#### 大表情消息 && gif表情消息
SDK 提供 `MMImageView` 来显示单个大表情及gif表情

`EaseBubbleView.h`、`EaseBubbleView+Gif`、`EaseBubbleView+Image`中的`UIImageView`相应的改成了`MMImageView`

`EaseCustomMessageCell`
```objectivec
- (void)setCustomModel:(id<IMessageModel>)model
{
	...
	else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
		...
		NSString *emojiCode = nil;
        if (model.mmExt[TEXT_MESG_DATA]) {
            emojiCode = model.mmExt[TEXT_MESG_DATA][0][0];
        }

        [self.bubbleView.imageView setImageWithEmojiCode:emojiCode];
        ...
	}
	...
}
```

布局：
`EaseCustomMessageCell`
```objectivec
- (void)layoutSubviews
{
    ...
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            //BQMM集成
            ...
            }else if ([self.model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]){
                //BQMM 集成 计算图片尺寸
                CGSize size =
                [MMImageView sizeForImageSize:CGSizeMake(kEMMessageImageSizeHeight, kEMMessageImageSizeHeight) imgMaxSize:CGSizeMake(kEMMessageImageSizeHeight, kEMMessageImageSizeHeight)];
                [self setBubbleWidth:size.width + self.bubbleMargin.left + self.bubbleMargin.right];
            }
            ...
        }
    }
    ...
}
```

gif表情
`EaseCustomMessageCell`
```objectivec
- (void)setCustomModel:(id<IMessageModel>)model
{
	...
	else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
		...
		NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];
        NSString *webStickerUrl = msgData[WEBSTICKER_URL];
        NSString *webStickerId = msgData[WEBSTICKER_ID];
        [self.bubbleView.imageView setImageWithUrl:webStickerUrl gifId:webStickerId];
        ...
	}
	...
}
```

布局：
`EaseCustomMessageCell`
```objectivec
- (void)layoutSubviews
{
    ...
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            //BQMM集成
            ...
            }else if ([self.model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]){
                //BQMM 集成 计算图片尺寸
                //宽最大200 高最大 150
                CGSize size =
                [MMImageView sizeForImageSize:CGSizeMake(self.model.gifSize.width, self.model.gifSize.height) imgMaxSize:CGSizeMake(200, 150)];
                [self setBubbleWidth:size.width + self.bubbleMargin.left + self.bubbleMargin.right];
            }
            ...
        }
    }
    ...
}
```


###7. demo中的其他修改
0. 相应的类中引用头文件。

1. `EaseCustomMessageCell`中的`isCustomBubbleView`用于根据消息类型来标识消息view是否需要自定义。
```objectivec
- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    BOOL flag = NO;
    switch (model.bodyType) {
        case EMMessageBodyTypeText:
        {
            if ([model.mmExt objectForKey:@"em_emotion"]) {
                flag = YES;
            }
            else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
                flag = YES;
            }
            else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
                flag = YES;
            }
            else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
                flag = YES;
            }
        }
            break;
        default:
            break;
    }    return flag;
    
}
```


2. `EaseMessageCell` 布局相关
```objectivec
//BQMM集成 便于布局记录下的参数
@property (nonatomic) CGFloat bubbleWidth UI_APPEARANCE_SELECTOR; //default 200;
@property (nonatomic) CGSize gifSize;

//BQMM集成
- (void)_updateBubbleWidthConstraint
{
    [self removeConstraint:self.bubbleMaxWidthConstraint];
    
    self.bubbleMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.bubbleWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
}

- (void)setBubbleWidth:(CGFloat)bubbleWidth
{
    _bubbleWidth = bubbleWidth;
    [self _updateBubbleWidthConstraint];
}
```

`EaseCustomMessageCell`
```objectivec
//BQMM集成   自定义气泡view的布局
- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        [_bubbleView setupMMTextBubbleViewWithModel:model];
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE] || [model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
    
}

//BQMM集成   更新气泡view的布局
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        [_bubbleView updateMMTextMargin:bubbleMargin];
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE] || [model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }
}

//BQMM集成  根据消息类型设置cell的 reuseCellIdentifier
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        return model.isSender?@"EaseMessageCellSendMMText":@"EaseMessageCellRecvMMText";
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }else if([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        return model.isSender?@"EaseMessageCellSendWebSticker":@"EaseMessageCellRecvWebSticker";
    }
    else {
        NSString *identifier = [EaseBaseMessageCell cellIdentifierWithModel:model];
        return identifier;
    }
}

//BQMM集成  计算消息cell的高度
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        return 100;
    }
    else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    ...
    switch (model.bodyType) {
        case EMMessageBodyTypeText:
        {
            UIFont *textFont = cell.messageTextFont;
            if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
                CGSize size = [MMTextParser sizeForMMTextWithExtData:model.mmExt[TEXT_MESG_DATA] font:textFont maximumTextWidth:bubbleMaxWidth];
                height += (size.height > 20 ? size.height : 20) + 4;
            }
            else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
                //BQMM 集成 计算图片尺寸
                CGSize size =
                [MMImageView sizeForImageSize:CGSizeMake(kEMMessageImageSizeHeight, kEMMessageImageSizeHeight) imgMaxSize:CGSizeMake(kEMMessageImageSizeHeight, kEMMessageImageSizeHeight)];
                height += size.height;
            }else if([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
                //BQMM 集成 计算图片尺寸
                //宽最大200 高最大 150
                CGSize size =
                [MMImageView sizeForImageSize:CGSizeMake(model.gifSize.width, model.gifSize.height) imgMaxSize:CGSizeMake(200, 150)];
                height += size.height;
            }
            else {
                NSString *text = model.text;
                CGRect rect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:textFont} context:nil];
                height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
            }
        }
        ...
        default:
            break;
    }
    
    height += EaseMessageCellPadding;
    model.cellHeight = height;
    return height;
}
```

3. 关闭商店相关

`EaseChatToolbar`
添加商店关闭观察者
```objectivec
- (instancetype)initWithFrame:(CGRect)frame
{
    ...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backToUserInterface)
                                                 name:@"SMEmotionDismissShopNotification"
                                               object:nil];
    ...
}

//去掉商店关闭观察者
- (void)dealloc
{
    //BQMM集成
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//BQMM集成 处理商店关闭事件
- (void)backToUserInterface {
    self.moreButton.selected = NO;
    if (!_inputTextView.isFirstResponder) {
        [_inputTextView becomeFirstResponder];
    }
    [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView];
    self.faceButton.selected = YES;
}

```

4. 标识消息是否是表情消息
`ChatViewController`
```objectivec
- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }else if(messageModel.mmExt != nil) {//BQMM集成
        return YES;
    }
    return flag;
}
```


###8. gif搜索模块UI定制

`BQMM_GIF`是一整套gif搜索UI模块的实现源码，可用于直接使用或用于参考实现gif搜索，及gif消息的发送解析。
####gif搜索源码说明
gif相关的功能由`MMGifManager`集中管理:

1.设置搜索模式的开启和关闭；指定输入控件
```objectivec
- (void)setSearchModeEnabled:(BOOL)enabled withInputView:(UIResponder<UITextInput> *_Nullable)input;
```

2.设置是否显示搜索出的表情内容；指定表情内容的显示位置
```objectivec
- (void)setSearchUiVisible:(BOOL)visible withAttatchedView:(UIView *_Nullable)attachedView;
```

3.通过`MMSearchModeStatus`管理搜索模式的开启和关闭及搜索内容的展示和收起（MMSearchModeStatus可自由调整）
```objectivec
typedef NS_OPTIONS (NSInteger, MMSearchModeStatus) {
    MMSearchModeStatusKeyboardHide = 1 << 0,         //收起键盘
    MMSearchModeStatusInputEndEditing = 1 << 1,         //收起键盘
    MMSearchModeStatusInputBecomeEmpty = 1 << 2,     //输入框清空
    MMSearchModeStatusInputTextChange = 1 << 3,      //输入框内容变化
    MMSearchModeStatusGifMessageSent = 1 << 4,       //发送了gif消息
    MMSearchModeStatusShowTrendingTriggered = 1 << 5,//触发流行表情
    MMSearchModeStatusGifsDataReceivedWithResult = 1 << 6,     //收到gif数据
    MMSearchModeStatusGifsDataReceivedWithEmptyResult = 1 << 7,     //搜索结果为空
};
- (void)updateSearchModeAndSearchUIWithStatus:(MMSearchModeStatus)status;
```

###9. UI定制

 SDK通过`MMTheme`提供一定程度的UI定制。具体参考类说明[MMTheme](../class_reference/README.md)。

创建一个`MMTheme`对象，设置相关属性， 然后[[MMEmotionCentre defaultCentre] setTheme:]即可修改商店和键盘样式。


###10. 清除缓存

调用`clearCache`方法清除缓存，此操作会删除所有临时的表情缓存，已下载的表情包不会被删除。建议在`- (void)applicationWillTerminate:(UIApplication *)application `方法中调用。

###11. 设置APP UserId

开发者可以用`setUserId`方法设置App UserId，以便在后台统计时跟踪追溯单个用户的表情使用情况。
