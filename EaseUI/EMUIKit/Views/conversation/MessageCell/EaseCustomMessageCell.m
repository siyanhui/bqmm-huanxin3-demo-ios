/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseCustomMessageCell.h"
#import "EaseBubbleView+Gif.h"
#import "UIImageView+EMWebCache.h"
#import "UIImageView+WebCache.h"
#import "UIImage+EMGIF.h"
#import "IMessageModel.h"
//BQMM集成
#import <BQMM/BQMM.h>
#import "EMBubbleView+MMText.h"
#import "MMTextView.h"

#import "UIImage+EMGIF.h"
#import "UIImageView+EMWebCache.h"
#import "MMGifManager.h"


@interface EaseCustomMessageCell ()

@end

@implementation EaseCustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell
//BQMM集成
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

//BQMM集成
- (void)setCustomModel:(id<IMessageModel>)model
{
    if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        [_bubbleView.textView setMmTextData:model.mmExt[TEXT_MESG_DATA]];
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE]) {
        //大表情显示
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSString *emojiCode = nil;
        if (model.mmExt[TEXT_MESG_DATA]) {
            emojiCode = model.mmExt[TEXT_MESG_DATA][0][0];
        }
        //兼容1.0之前（含）版本的消息格式
        else {
            emojiCode = model.text;
        }
        
        if (emojiCode != nil && emojiCode.length > 0) {
            self.bubbleView.imageView.errorImage = [UIImage imageNamed:@"mm_emoji_error"];
            self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
            [self.bubbleView.imageView setImageWithEmojiCode:emojiCode];
        }else {
            self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
        }
        
    }else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {

        NSDictionary *msgData = model.mmExt[TEXT_MESG_DATA];
        NSString *webStickerUrl = msgData[WEBSTICKER_URL];
        NSString *webStickerId = msgData[WEBSTICKER_ID];
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        self.bubbleView.imageView.errorImage = [UIImage imageNamed:@"mm_emoji_error"];
        [self.bubbleView.imageView setImageWithUrl:webStickerUrl gifId:webStickerId];
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

//BQMM集成
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

//BQMM集成
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_EMOJI_TYPE]) {
        [_bubbleView updateMMTextMargin:bubbleMargin];
    }
    else if ([model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_FACE_TYPE] || [model.mmExt[TEXT_MESG_TYPE] isEqualToString:TEXT_MESG_WEB_TYPE]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }
}

//BQMM集成
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

//BQMM集成
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

@end

