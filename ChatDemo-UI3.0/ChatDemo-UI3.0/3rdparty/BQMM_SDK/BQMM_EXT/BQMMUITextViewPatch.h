////
////  BQMMUITextViewPatch.h
////  StampMeSDK
////
////  Created by Tender on 2016/12/26.
////  Copyright © 2016年 siyanhui. All rights reserved.
////
//
#ifndef BQMMUITextViewPatch_h
#define BQMMUITextViewPatch_h

#import <UIKit/UIKit.h>
#import <BQMM/BQMM.h>

@interface BQMMUITextViewPatch : NSObject

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSAttributedString *attributedText;

@end

#endif /* BQMMUITextViewPatch_h */
