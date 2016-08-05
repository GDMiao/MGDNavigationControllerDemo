//
//  HFBrowserView.h
//  HGYProject
//
//  Created by HF Zhao on 13-8-3.
//  Copyright (c) 2013年 HuiGeYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HFBrowserView;
@protocol HFBrowserViewSourceDelegate <NSObject>
- (NSUInteger)numberOfPageInBrowserView:(HFBrowserView *)browser;
- (UIView *)browserView:(HFBrowserView *)browser viewAtIndex:(NSUInteger)index;
@end

@protocol HFBrowserViewDelegate <NSObject>
@optional
//代码调用setContentOffset滚动停止
- (void)browserViewlDidEndScrollingAnimation:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex;
//拖动调用后，滚动停止
- (void)browserViewlDidEndDecelerating:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex;
- (void)browserViewlEndScrollingLeft:(HFBrowserView *)browser;//已经第一页了
- (void)browserViewlEndScrollingRight:(HFBrowserView *)browser;//已经最后一页了
//将要显示第几个 如果没有动画切换效果就是显示的视图
- (void)browserViewlWillSelect:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex;
@end

@interface HFBrowserView : UIScrollView<UIScrollViewDelegate>
{
    NSUInteger _pageCount;
    NSMutableSet *_visiblePages, *_recycledPages;
	NSUInteger _currentPageIndex;
	NSUInteger _pageIndexBeforeRotation;
    BOOL _performingLayout;
    BOOL isReload;
}
@property (nonatomic,assign) IBOutlet id<HFBrowserViewSourceDelegate> sourceDelegate;
@property (nonatomic,assign) IBOutlet id<HFBrowserViewDelegate> dragDelegate;
// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setInitialPageIndex:(NSUInteger)index;
-(void)setInitialPageIndex:(NSUInteger)index animated:(BOOL)animated;
-(UIView *)getCurrentView;//获取当前视图
-(UIView *)getView:(int)index;//获取对应位置的视图

-(int) getCurrentPage;
@end
