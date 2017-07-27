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
#import "UIImage+EMGIF.h"
#import "IMessageModel.h"
//BQMM集成
#import <BQMM/BQMM.h>
#import "EMBubbleView+MMText.h"
#import "MMTextView.h"


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
            else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
                flag = YES;
            }
            else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
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
    if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView.textView setMmTextData:model.mmExt[@"msg_data"]];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        //大表情显示
        self.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSArray *codes = nil;
        if (model.mmExt[@"msg_data"]) {
            codes = @[model.mmExt[@"msg_data"][0][0]];
        }
        //兼容1.0之前（含）版本的消息格式
        else {
            codes = @[model.text];
        }
        self.bubbleView.imageView.tag ++;
        __block NSInteger tag = self.bubbleView.imageView.tag;
        __weak typeof(self) weakSelf = self;
        [[MMEmotionCentre defaultCentre] fetchEmojisByType:MMFetchTypeBig codes:codes completionHandler:^(NSArray *emojis) {
            if (tag != weakSelf.bubbleView.imageView.tag) {
                return;
            }
            if (emojis.count > 0) {
                MMEmoji *emoji = emojis[0];
                if ([weakSelf.model.mmExt[@"msg_data"][0][0] isEqualToString:emoji.emojiCode]) {
                    if (emoji.emojiImage) {
                        if(emojis.count == 1) {
                            weakSelf.bubbleView.imageView.image = emoji.emojiImage;
                        }else{
                            weakSelf.bubbleView.imageView.animationImages = emoji.emojiImage.images;
                            weakSelf.bubbleView.imageView.image = emoji.emojiImage.images[0];
                            weakSelf.bubbleView.imageView.animationDuration = emoji.emojiImage.duration;
                            [weakSelf.bubbleView.imageView startAnimating];
                        }
                    }else{
                        NSLog(@"weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@mm_emoji_error]");
                        weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
                    }
                }
            }
            else {
                weakSelf.bubbleView.imageView.image = [UIImage imageNamed:@"mm_emoji_error"];
            }
        }];

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
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView setupMMTextBubbleViewWithModel:model];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        [_bubbleView setupGifBubbleView];
        
        _bubbleView.imageView.image = [UIImage imageNamed:model.failImageName];
    }

}

//BQMM集成
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        [_bubbleView updateMMTextMargin:bubbleMargin];
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        [_bubbleView updateGifMargin:bubbleMargin];
    }
}

//BQMM集成
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    if ([model.mmExt objectForKey:@"em_emotion"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"emojitype"]) {
        return model.isSender?@"EaseMessageCellSendMMText":@"EaseMessageCellRecvMMText";
    }
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
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
    else if ([model.mmExt[@"txt_msgType"] isEqualToString:@"facetype"]) {
        return kEMMessageImageSizeHeight;
    }
    else {
        CGFloat height = [EaseBaseMessageCell cellHeightWithModel:model];
        return height;
    }
}

@end
