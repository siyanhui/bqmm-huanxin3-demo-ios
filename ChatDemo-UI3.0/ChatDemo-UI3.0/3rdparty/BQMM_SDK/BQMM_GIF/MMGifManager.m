//
//  MMWebPicManager.m
//  StampMeSDK
//
//  Created by isan on 21/11/2017.
//  Copyright © 2017 siyanhui. All rights reserved.
//

#import "MMGifManager.h"
#import "DXPopover.h"
#import "UIImage+GIF.h"
#import "Masonry.h"
#import "MMGifCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define MMMaxTipCount 20
#define MMTIPHEIGHT 80
#define MMEmojiMargin 10
#define MMTIPDuration 5.0

@interface MMGifManager ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate> {
    BOOL searchModeEnabled;
    BOOL searchUiVisible;
    
    NSMutableArray<MMGif *> *gifsArray;
    int currentPage;
    int pageSize;
    NSString *currentKey;
    BOOL showingTrending;
    BOOL loadingMore;
    BOOL loadingFinished;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, weak) UIView *attchedView;
@property (nonatomic, weak) UIResponder<UITextInput> *inputView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *contentView;
@property(strong, nonatomic) UIView *loadingView;
@property(strong, nonatomic) UIButton *reloadButton;
@property(strong, nonatomic) UILabel *emptyLabel;
@property(strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@end
static MMGifManager *_defaultManager = nil;

@implementation MMGifManager
+ (MMGifManager *)defaultManager {
    if (!_defaultManager) {
        _defaultManager = [[MMGifManager alloc] init];
    }
    return _defaultManager;
}

- (instancetype)init
{
    self = [super init];
    gifsArray = [[NSMutableArray alloc] initWithCapacity:0];
    pageSize = 20;
    return self;
}

#pragma mark -- UI初始化
- (DXPopover *)popover {
    if (_popover == nil) {
        _popover = [DXPopover popover];
        _popover.animated = NO;
        _popover.maskType = DXPopoverMaskTypeNone;
        _popover.arrowSize = CGSizeZero;
    }
    return _popover;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLaout = [[UICollectionViewFlowLayout alloc] init];
        flowLaout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLaout.itemSize = CGSizeMake(MMTIPHEIGHT, MMTIPHEIGHT);
        flowLaout.minimumInteritemSpacing = MMEmojiMargin;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MMTIPHEIGHT, MMTIPHEIGHT) collectionViewLayout:flowLaout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[MMGifCell class]
            forCellWithReuseIdentifier:NSStringFromClass([MMGifCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        CGFloat screenWith = [[UIScreen mainScreen] bounds].size.width;
        _contentView.frame = CGRectMake(0, 0, screenWith, MMTIPHEIGHT + 8);
        [self initContentViewAssistView];
        [_contentView addSubview:[self collectionView]];
    }
    
    self.collectionView.frame = CGRectMake(8, 8, _contentView.frame.size.width - 16, _contentView.frame.size.height - 16);
    [self.collectionView reloadData];
    return _contentView;
}

- (void)initContentViewAssistView {
    _loadingView = [UIView new];
    _loadingView.backgroundColor = [UIColor whiteColor];
    [_contentView addSubview:_loadingView];
    
    CGRect contentViewFrame = _contentView.frame;
    _loadingView.frame = CGRectMake(0, 1, contentViewFrame.size.width, contentViewFrame.size.height - 2);
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView addSubview:_loadingIndicator];
    _loadingIndicator.frame = CGRectMake((contentViewFrame.size.width - 60) / 2, (contentViewFrame.size.height - 2 - 60) / 2, 60, 60);
    
    _emptyLabel = [UILabel new];
    _emptyLabel.text = @"没有表情";
    _emptyLabel.backgroundColor = [UIColor clearColor];
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.font = [UIFont systemFontOfSize:17];
    [_loadingView addSubview:_emptyLabel];
    _emptyLabel.frame = CGRectMake(0, 0, contentViewFrame.size.width, contentViewFrame.size.height - 2);
    _emptyLabel.hidden = true;
    
    _reloadButton = [UIButton new];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [_reloadButton setTitleColor:[UIColor colorWithWhite:100.0 / 255 alpha:1.0] forState:UIControlStateNormal];
    _reloadButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
//    [_reloadButton addTarget:self action:@selector(reloadFailData) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.layer.cornerRadius = 2;
    _reloadButton.layer.borderWidth = 1;
    _reloadButton.layer.borderColor = [UIColor colorWithWhite:225.0 / 255 alpha:1.0].CGColor;
    [_loadingView addSubview:_reloadButton];
    _reloadButton.frame = CGRectMake(0, 0, contentViewFrame.size.width, contentViewFrame.size.height - 2);
    _reloadButton.hidden = true;
}


- (void)dealloc
{
    _attchedView = nil;
    _inputView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -- 通知处理
- (void)textFieldDidEndEditing:(NSNotification *)notification {
    if (notification.object == _inputView && _inputView) {
        [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusInputEndEditing];
    }
}

- (void)textViewDidEndEditing:(NSNotification *)notification {
    if (notification.object == _inputView && _inputView) {
        [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusInputEndEditing];
    }
}

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == _inputView && _inputView) {
        //获取输入框文字
        NSString *currentText = nil;
        if ([_inputView isKindOfClass:[UITextField class]]) {
            currentText = [(UITextField *)_inputView text];
        } else if ([_inputView isKindOfClass:[UITextView class]]) {
            currentText = [(UITextView *)_inputView text];
        }
        currentText = [currentText stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //跟当前key比较
        if (currentText == currentKey) {
            return;
        }
        
        [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusInputTextChange];
        if ([currentText length] <= 0) {
            [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusInputBecomeEmpty];
            return;
        }
        
        if ([currentText length] >= 5) {
            currentKey = currentText;
            return;
        }
        
        //搜索
        [self searchEmojisWith:currentText];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusKeyboardHide];
}

#pragma mark -- scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        [_timer invalidate];
        if (!loadingMore) {
            CGPoint offSet = _collectionView.contentOffset;
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            if (offSet.x + width  > _collectionView.contentSize.width + 30) {
                loadingMore = true;
                [self loadNextPage];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:MMTIPDuration
                                                  target:self
                                                selector:@selector(dismissWebPic)
                                                userInfo:nil
                                                 repeats:NO];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _timer = [NSTimer scheduledTimerWithTimeInterval:MMTIPDuration
                                              target:self
                                            selector:@selector(dismissWebPic)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)searchEmojisWith:(NSString *)key {
    currentKey = key;
    currentPage = 1;
    
    showingTrending = false;
    loadingMore = false;
    loadingFinished = false;

    
    [gifsArray removeAllObjects];
    _emptyLabel.hidden = true;
    _loadingIndicator.hidden = false;
    
    [_contentView bringSubviewToFront:_loadingView];
    [_loadingIndicator startAnimating];
    [self getSearchGifsAtPage:currentPage];
}

- (void)loadNextPage {
    if (loadingFinished) {
        return;
    }
    currentPage = currentPage + 1;
    if (showingTrending) {
        [self getTrendingGifsAtPage:currentPage];
    }else{
        
    }
}

#pragma mark - CollctionView Datasource/delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return gifsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMGifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MMGifCell class]) forIndexPath:indexPath];
    if (indexPath.row < gifsArray.count) {
        MMGif *gif = gifsArray[indexPath.row];
        [cell setData:gif];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < gifsArray.count) {
        MMGifCell *cell = (MMGifCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.emojiImageView.userInteractionEnabled) {
            return;
        }
        [self updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusGifMessageSent];
        if (self.selectedHandler) {
            MMGif *gif = cell.picture;
            self.selectedHandler(gif);
        }
    }
}

#pragma mark -- popover 管理
- (void)updateSearchModeAndSearchUIWithStatus:(MMSearchModeStatus)status {
    if (status & MMSearchModeStatusShowTrendingTriggered) {
        [self showWebStickers];
    }else{
        if (searchModeEnabled && searchUiVisible) {
            if (status & MMSearchModeStatusKeyboardHide) {
                [self dismissWebPic];
                return;
            }
            
            if (status & MMSearchModeStatusInputTextChange) {
                [self dismissWebPic];
                return;
            }
            
            
            if (status & MMSearchModeStatusSearchResultEmpty) {
//                [self dismissWebPic];
                [self showWebStickers];
                return;
            }
            
            if (status & MMSearchModeStatusInputEndEditing) {
                [self dismissWebPic];
                return;
            }
            
            if (status & MMSearchModeStatusGifsDataReceived) {
                [self showWebStickers];
                return;
            }
            
            if (status & MMSearchModeStatusInputBecomeEmpty) {
                [self dismissWebPic];
                searchModeEnabled = NO;
                searchUiVisible = NO;
                return;
            }
            
            if (status & MMSearchModeStatusGifMessageSent) {
                [self dismissWebPic];
                searchModeEnabled = NO;
                searchUiVisible = NO;
                return;
            }
        }else{
            [self dismissWebPic];
        }
    }
}

- (void)showWebStickers {
    if (_attchedView == nil) {
        return;
    }
    [_collectionView setContentOffset:CGPointMake(0, 0) animated:false];
    [_timer invalidate];
    UIViewController *topController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    CGRect rect = [_attchedView convertRect:_attchedView.bounds toView:topController.view];
    CGPoint attachedPoint = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y - 10);
    [self.popover showAtPoint:attachedPoint popoverPostion:DXPopoverPositionUp withContentView:self.contentView inView:topController.view];
    _timer = [NSTimer scheduledTimerWithTimeInterval:MMTIPDuration
                                              target:self
                                            selector:@selector(dismissWebPic)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)dismissWebPic {
    [_timer invalidate];
    [self.popover dismiss];
}

- (void)deAttach {
    _inputView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -- 搜索设置
- (void)setSearchModeEnabled:(BOOL)enabled withInputView:(UIResponder<UITextInput> *_Nullable)input{
    searchModeEnabled = enabled;
    if (!enabled) {
        [self deAttach];
        return;
    }
    
    if (_inputView == input) {
        return;
    } else {
        [self deAttach];
        _inputView = input;
        if ([_inputView isKindOfClass:[UITextField class]]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textDidChange:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:_inputView];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textFieldDidEndEditing:)
                                                         name:UITextFieldTextDidEndEditingNotification
                                                       object:_inputView];
        } else if ([_inputView isKindOfClass:[UITextView class]]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textDidChange:)
                                                         name:UITextViewTextDidChangeNotification
                                                       object:_inputView];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textViewDidEndEditing:)
                                                         name:UITextViewTextDidEndEditingNotification
                                                       object:_inputView];
            
            
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)setSearchUiVisible:(BOOL)visible withAttatchedView:(UIView *_Nullable)attachedView{
    searchUiVisible = visible;
    _attchedView = attachedView;
}

- (void)showTrending {
    [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    currentPage = 1;
    showingTrending = YES;
    [_contentView bringSubviewToFront:_loadingView];
    [_loadingIndicator startAnimating];
    [self getTrendingGifsAtPage:currentPage];
}

#pragma mark -- 数据
-(void)getTrendingGifsAtPage:(int)page {
    __weak MMGifManager *weakSelf = self;
    [[MMEmotionCentre defaultCentre] trendingGifsAt:currentPage withPageSize:pageSize completionHandler:^(NSArray<MMGif *> * _Nullable gifs, NSError * _Nullable error) {
        
        loadingMore = false;
        [_contentView bringSubviewToFront:_collectionView];
        if(currentPage == 1) {
            [gifsArray removeAllObjects];
            [_collectionView setContentOffset:CGPointMake(0, 0)];
            [weakSelf updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusShowTrendingTriggered];
            if (gifs.count <= 0) {
                [_contentView bringSubviewToFront:_loadingView];
                [self.loadingIndicator stopAnimating];
                self.loadingIndicator.hidden = true;
                self.emptyLabel.hidden = false;
                return;
            }
        }
        
        if (gifs.count > 0) {
            [gifsArray addObjectsFromArray:gifs];
            [_collectionView reloadData];
        }else{
            currentPage -= 1;
            if (currentPage < 1) {
                currentPage = 1;
            }
            loadingFinished = true;
        }
        
        if (currentPage == 5) {
            loadingFinished = true;
        }
    }];
}

-(void)getSearchGifsAtPage:(int)page {
    __weak MMGifManager *weakSelf = self;
    [[MMEmotionCentre defaultCentre] searchGifsWithKey:currentKey At:page withPageSize:pageSize completionHandler:^(NSString * __nonnull searchKey, NSArray<MMGif *> * _Nullable gifs, NSError * _Nullable error) {
        if (weakSelf == nil) {
            return;
        }
        if (searchKey != currentKey) {
            return;
        }
        loadingMore = false;
        [_contentView bringSubviewToFront:_collectionView];
        if(currentPage == 1) {
            [gifsArray removeAllObjects];
            [_collectionView setContentOffset:CGPointMake(0, 0)];
            if (gifs.count <= 0) {
                [_contentView bringSubviewToFront:_loadingView];
                [self.loadingIndicator stopAnimating];
                self.loadingIndicator.hidden = true;
                self.emptyLabel.hidden = false;
                [weakSelf updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusSearchResultEmpty];
                return;
            }else{
                [weakSelf updateSearchModeAndSearchUIWithStatus:MMSearchModeStatusGifsDataReceived];
            }
        }
        
        if (gifs.count > 0) {
            [gifsArray addObjectsFromArray:gifs];
            [_collectionView reloadData];
        }else{
            currentPage -= 1;
            if (currentPage < 1) {
                currentPage = 1;
            }
            loadingFinished = true;
        }
        
        if (currentPage == 5) {
            loadingFinished = true;
        }
    }];
}

@end
