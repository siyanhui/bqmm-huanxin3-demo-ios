#环信3.0 iOS接入说明

##0. 导入资源文件

主工程和EaseUI都需要加入`BQMM.framework`和`BQMM.bundle`。

另外，EaseUI中需加入：

* `emoji_placeholder.png`
* `MMTextParser+ExtData.h`
* `MMTextParser+ExtData.m` 
* `MMTextView.h` 
* `MMTextView.m`

主工程中加入

* `emoji_placeholder.png`
* `MMTextParser+ExtData.h`
* `MMTextView.h`

##1. 注册AppId&AppSecret

在`AppDelegate `的方法`application:didFinishLaunchingWithOptions:`中加入

```
[[MMEmotionCentre defaultCentre] setAppId:@"YOUR_APP_ID" secret:@"YOUR_SECRET"];
```

`applicationWillEnterForeground:`中加入

```
[[MMEmotionCentre defaultCentre] clearSession];
```

##2. 添加表情mm键盘
在`EaseChatToolbar`类中添加表情键盘相关方法。

###2.1 设置SDK代理

在`initWithFrame`中加入以下代码

```objectivec
[MMEmotionCentre defaultCentre].delegate = self;
```

###2.2 实现表情键盘和普通键盘切换按钮

```objectivec
- (void)faceButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    EaseChatToolbarItem *faceItem = nil;
    for (EaseChatToolbarItem *item in self.rightItems) {
        if (item.button == button){
            faceItem = item;
            continue;
        }
        
        item.button.selected = NO;
    }
    
    for (EaseChatToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    //替换成表情MM键盘
    if (button.isSelected) {
        self.moreButton.selected = NO;
        
        if (!_inputTextView.isFirstResponder) {
            [_inputTextView becomeFirstResponder];
        }
        //添加表情键盘
        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView];
        self.faceButton.selected = YES;
    }
    else {
        //切换为普通键盘
        [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    }
}
```


###2.3 添加大表情联想输入

在`_setupSubviews`方法中添加表情联想输入框

```objectivec
[[MMEmotionCentre defaultCentre] shouldShowShotcutPopoverAboveView:self.faceButton withInput:self.inputTextView];
```

###2.4 实现表情发送代理方法

```objectivec
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
        [self _willShowInputTextViewToHeight:[self _getTextViewContentH:_inputTextView]];
    }
}

//点击输入框切换表情按钮状态
- (void)tapOverlay
{
    self.faceButton.selected = NO;
}

```

##3. 表情消息编辑和发送

在`EaseMessageViewController`中实现大小表情消息的发送方法。

###3.1 发送文字（包含小表情图文混排）消息
修改原有文本消息的发送方法。

```objectivec
- (void)sendTextMessage:(NSString *)text
{
    NSString *text_ = [text stringByReplacingOccurrencesOfString:@"\a" withString:@""];
    [MMTextParser localParseMMText:text_ completionHandler:^(NSArray *textImgArray) {
        NSDictionary *ext = nil;
        NSString *sendStr = @"";
        for (id obj in textImgArray) {
            if ([obj isKindOfClass:[MMEmoji class]]) {
                MMEmoji *emoji = (MMEmoji*)obj;
                //表情mm 默认的扩展消息格式，"emojitype"代表小表情消息
                if (!ext) {
                    ext = @{@"txt_msgType":@"emojitype",
                            @"msg_data":[MMTextParser extDataWithTextImageArray:textImgArray]};
                }
                //将emojiName显示在消息文本
                sendStr = [sendStr stringByAppendingString:[NSString stringWithFormat:@"[%@]", emoji.emojiName]];
            }
            else if ([obj isKindOfClass:[NSString class]]) {
                sendStr = [sendStr stringByAppendingString:obj];
            }
        }
        [self sendTextMessage:sendStr withExt:ext];
    }];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:self.conversation.chatter
                                            messageType:[self _messageTypeFromConversationType]
                                      requireEncryption:NO
                                             messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

```

###3.2 发送大表情消息
新增发送大表情的方法
```objectivec
-(void)sendMMFaceMessage:(MMEmoji *)emoji
{
    //表情mm 默认的扩展消息格式，"facetype"代表小表情消息
    NSDictionary *ext = @{@"txt_msgType":@"facetype",
                          @"msg_data":[MMTextParser extDataWithEmojiCode:emoji.emojiCode]};
    [self sendMMFaceMessage:emoji withExt:ext];
}

-(void)sendMMFaceMessage:(MMEmoji *)emoji withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:[NSString stringWithFormat:@"[%@]", emoji.emojiName]
                                                     to:self.conversation.chatter
                                            messageType:[self _messageTypeFromConversationType]
                                      requireEncryption:NO
                                             messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}
```


###3.3 实现消息编辑控件的复制和剪切
在`EaseTextView`中新增下面两个方法

```objectivec
- (void)copy:(id)sender
{
    [UIPasteboard generalPasteboard].string = [self mmTextWithRange:self.selectedRange];
}

- (void)cut:(id)sender
{
    [UIPasteboard generalPasteboard].string = [self mmTextWithRange:self.selectedRange];
    NSRange range  = [self.mmText rangeOfString:[UIPasteboard generalPasteboard].string];
    NSString *left = [self.mmText substringToIndex:range.location];
    NSString *right = [self.mmText substringFromIndex:range.location + range.length];
    NSRange selectedRange = self.selectedRange;
    self.mmText = [NSString stringWithFormat:@"%@%@", left, right];
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
    [self.delegate textViewDidChange:self];
}
```


###做什么用的啊

`textView:shouldChangeTextInRange:replacementText:`中`textView.text`改成`textView.mmText`

###这又是做什么用的啊

```
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.mmText];
            self.inputTextView.text = @"";
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];;
        }
        
        return NO;
    }
    return YES;
}
```


###监听textView的Change事件
textViewDidChange:修改成如下代码


```objectivec
if (textView.markedTextRange == nil) {
    NSRange range = textView.selectedRange;
    textView.mmText = textView.mmText;
    textView.selectedRange = range;
}
[self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView]];
```

##自定义表情消息



##4. 表情消息

###添加查看表情详情

`EaseMessageViewController`

`messageCellSelected:`中 `case eMessageBodyType_Text:`加入如下代码，实现点击打开表情详情页。在详情页中，可直接下载相关表情包。

```objectivec
if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
    //"facetype"代表大表情消息类型
    [self.chatToolbar endEditing:YES];//在endEditing中关闭键盘
    UIViewController *emojiController = [[MMEmotionCentre defaultCentre] controllerForEmotionCode:model.message.ext[@"msg_data"][0][0]];
    [self.navigationController pushViewController:emojiController animated:YES];
}
```


###实现表情消息的复制

修改`ChatViewController`类中`copyMenuAction`方法。

```
- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
            pasteboard.string = [MMTextParser stringWithExtData:model.message.ext[@"msg_data"]];
        }
        else {
            pasteboard.string = model.text;
        }
    }
    
    self.menuIndexPath = nil;
}
```


EaseBaseMessageCell

`layoutSubviews`中 `case eMessageBodyType_Text:`加入如下代码

```
if ([self.model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
    MMTextView *textView = [[MMTextView alloc] init];
    textView.mmFont = [UIFont systemFontOfSize:15];
    [textView setMmTextData:self.model.message.ext[@"msg_data"]];
    CGSize retSize = [textView sizeThatFits:CGSizeMake(175, CGFLOAT_MAX)];
    [self setBubbleWidth:retSize.width + 25];
}
```



EaseMessageCell
`cellHeightWithModel:`中 `case eMessageBodyType_Text:`修改成如下代码

```
if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
    MMTextView *textView = [[MMTextView alloc] init];
    textView.mmFont = [UIFont systemFontOfSize:15];
    [textView setPlaceholderTextWithData:model.message.ext[@"msg_data"]];
    CGSize size = [textView sizeThatFits:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX)];
    
    height += size.height;
}
else {
    NSString *text = model.text;
    UIFont *textFont = cell.messageTextFont;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:textFont} context:nil];
    height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
}

```


###4.1 设置自定义消息Cell

`EMBubbleView+MMText`


在`CustomMessageCell`的方法中加入表情消息的处理。

以下方法中加入txt_msgType的判断 具体代码参考demo（EMBubbleView+MMText类可以直接用demo中的）

isCustomBubbleView:
setCustomModel:
setCustomBubbleView:
updateCustomBubbleViewMargin:model:
cellIdentifierWithModel:
cellHeightWithModel:


```
- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    BOOL flag = NO;
    switch (model.bodyType) {
        case eMessageBodyType_Text:
        {
            if ([model.message.ext objectForKey:@"em_emotion"]) {
                flag = YES;
            }
            else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
                flag = YES;
            }
            else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
                flag = YES;
            }
        }
            break;
        default:
            break;
    }
    return flag;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        UIImage *image = [EMGifImage imageNamed:[model.message.ext objectForKey:@"em_emotion"]];
        if (!image) {
            image = model.image;
            if (!image) {
                image = [UIImage imageNamed:model.failImageName];
            }
        }
        _bubbleView.imageView.image = image;
        [self.avatarView imageWithUsername:model.nickname placeholderImage:nil];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView.textView setMmTextData:model.message.ext[@"msg_data"]];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
        //大表情显示
        self.bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
        NSArray *codes = nil;
        if (model.message.ext[@"msg_data"]) {
            codes = @[model.message.ext[@"msg_data"][0][0]];
        }
        //兼容1.0之前（含）版本的消息格式
        else {
            codes = @[model.text];
        }
        __weak typeof(self) weakSelf = self;
        [[MMEmotionCentre defaultCentre] fetchEmojisByType:MMFetchTypeBig codes:codes completionHandler:^(NSArray *emojis, NSError *error) {
            if (emojis.count > 0) {
                MMEmoji *emoji = emojis[0];
                if ([weakSelf.model.message.ext[@"msg_data"][0][0] isEqualToString:emoji.emojiCode]) {
                    weakSelf.bubbleView.imageView.image = emoji.emojiImage;
                }
            }
            else {
                weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error.png"];
            }
        }];
        [self.avatarView imageWithUsername:model.nickname placeholderImage:nil];
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView setupMMTextBubbleViewWithModel:model];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView updateMMTextMargin:bubbleMargin];
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }
}


+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        return model.isSender?@"EaseMessageCellSendMMText":@"EaseMessageCellRecvMMText";
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else {
        NSString *identifier = [EaseBaseMessageCell cellIdentifierWithModel:model];
        return identifier;
    }
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if ([model.message.ext objectForKey:@"em_emotion"]) {
        return 100;
    }
    else if ([model.message.ext[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return kEMMessageImageSizeHeight;
    }
    else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}
```