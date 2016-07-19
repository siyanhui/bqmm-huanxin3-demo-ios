/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseConvertToCommonEmoticonsHelper.h"
#import "EaseEmoji.h"

@implementation EaseConvertToCommonEmoticonsHelper

#pragma mark - emotics

//BQMM集成   去除环信本身表情映射
+ (NSString *)convertToCommonEmoticons:(NSString *)text
{
    return text;
//    int allEmoticsCount = (int)[EaseEmoji allEmoji].count;
//    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];
//    for(int i=0; i<allEmoticsCount; ++i) {
//        NSRange range;
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😊"
//                                 withString:@"[):]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😃"
//                                 withString:@"[:D]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😉"
//                                 withString:@"[;)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😮"
//                                 withString:@"[:-o]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😋"
//                                 withString:@"[:p]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😎"
//                                 withString:@"[(H)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😡"
//                                 withString:@"[:@]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😖"
//                                 withString:@"[:s]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😳"
//                                 withString:@"[:$]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😞"
//                                 withString:@"[:(]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😭"
//                                 withString:@"[:'(]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😐"
//                                 withString:@"[:|]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😇"
//                                 withString:@"[(a)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😬"
//                                 withString:@"[8o|]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😆"
//                                 withString:@"[8-|]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😱"
//                                 withString:@"[+o(]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🎅"
//                                 withString:@"[<o)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😴"
//                                 withString:@"[|-)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😕"
//                                 withString:@"[*-)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😷"
//                                 withString:@"[:-#]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😯"
//                                 withString:@"[:-*]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😏"
//                                 withString:@"[^o)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"😑"
//                                 withString:@"[8-)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"💖"
//                                 withString:@"[(|)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"💔"
//                                 withString:@"[(u)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🌙"
//                                 withString:@"[(S)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🌟"
//                                 withString:@"[(*)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🌞"
//                                 withString:@"[(#)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🌈"
//                                 withString:@"[(R)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        
//        [retText replaceOccurrencesOfString:@"😚"
//                                 withString:@"[(})]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        
//        [retText replaceOccurrencesOfString:@"😍"
//                                 withString:@"[({)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"💋"
//                                 withString:@"[(k)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🌹"
//                                 withString:@"[(F)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"🍂"
//                                 withString:@"[(W)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"👍"
//                                 withString:@"[(D)]"
//                                    options:NSLiteralSearch
//                                      range:range];
//    }
//    
//    return retText;
}

+ (NSString *)convertToSystemEmoticons:(NSString *)text
{
    return text;
//    if (![text isKindOfClass:[NSString class]]) {
//        return @"";
//    }
//    
//    if ([text length] == 0) {
//        return @"";
//    }
//    int allEmoticsCount = (int)[[EaseEmoji allEmoji] count];
//    NSMutableString *retText = [[NSMutableString alloc] initWithString:text];
//    for(int i=0; i<allEmoticsCount; ++i) {
//        NSRange range;
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[):]"
//                                 withString:@"😊"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:D]"
//                                 withString:@"😃"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[;)]"
//                                 withString:@"😉"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:-o]"
//                                 withString:@"😮"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:p]"
//                                 withString:@"😋"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(H)]"
//                                 withString:@"😎"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:@]"
//                                 withString:@"😡"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:s]"
//                                 withString:@"😖"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:$]"
//                                 withString:@"😳"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:(]"
//                                 withString:@"😞"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:'(]"
//                                 withString:@"😭"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:|]"
//                                 withString:@"😐"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(a)]"
//                                 withString:@"😇"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[8o|]"
//                                 withString:@"😬"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[8-|]"
//                                 withString:@"😆"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[+o(]"
//                                 withString:@"😱"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[<o)]"
//                                 withString:@"🎅"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[|-)]"
//                                 withString:@"😴"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[*-)]"
//                                 withString:@"😕"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:-#]"
//                                 withString:@"😷"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[:-*]"
//                                 withString:@"😯"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[^o)]"
//                                 withString:@"😏"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[8-)]"
//                                 withString:@"😑"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(|)]"
//                                 withString:@"💖"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(u)]"
//                                 withString:@"💔"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(S)]"
//                                 withString:@"🌙"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(*)]"
//                                 withString:@"🌟"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(#)]"
//                                 withString:@"🌞"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(R)]"
//                                 withString:@"🌈"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        
//        [retText replaceOccurrencesOfString:@"[(})]"
//                                 withString:@"😚"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        
//        [retText replaceOccurrencesOfString:@"[({)]"
//                                 withString:@"😍"
//                                    options:NSLiteralSearch
//                                      range:range];
//
//        
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(k)]"
//                                 withString:@"💋"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(F)]"
//                                 withString:@"🌹"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(W)]"
//                                 withString:@"🍂"
//                                    options:NSLiteralSearch
//                                      range:range];
//        
//        range.location = 0;
//        range.length = retText.length;
//        [retText replaceOccurrencesOfString:@"[(D)]"
//                                 withString:@"👍"
//                                    options:NSLiteralSearch
//                                      range:range];
//    }
//    
//    return retText;
}

@end
