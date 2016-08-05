//
//  ViewController.m
//  MGDNavigationControllerDemo
//
//  Created by miaoguodong on 16/8/5.
//  Copyright © 2016年 miaoguodong. All rights reserved.
//

#import "ViewController.h"
#import "HMSegmentedControl.h"
#import "HFBrowserView.h"
#import "HomeViewController.h"
#import "SeconedViewController.h"
#import "ThirdViewController.h"
#import "UIViewExt.h"

#define DefaultSelectedIndex 0

@interface ViewController ()<HFBrowserViewSourceDelegate,HFBrowserViewDelegate>

@property (nonatomic, strong) HFBrowserView *browserView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect hmsegmentedRect = CGRectMake(50, 20, self.view.bounds.size.width - 100, 44);
    self.segmentedControl = [[HMSegmentedControl alloc]initWithFrame:hmsegmentedRect];
    self.segmentedControl.sectionTitles = @[@"Home",@"Seconed",@"Third"];
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]};
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor redColor];
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
//    [self.view addSubview:self.segmentedControl];
    
    self.browserView = [[HFBrowserView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    self.browserView.bounces = NO;
    self.browserView.scrollEnabled = YES;
    self.browserView.sourceDelegate = self;
    self.browserView.dragDelegate = self;
    self.browserView.clipsToBounds = NO;
    [self.browserView setInitialPageIndex:0];
    [self.view addSubview:self.browserView];
    [self.browserView reloadData];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)segmentedControlChangedValue
{
    NSLog(@"segmentedControlChangedValue");
}
- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}
#pragma mark -
#pragma mark - 选择控件事件回调
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [self.browserView setInitialPageIndex:segmentedControl.selectedSegmentIndex animated:YES];
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}


#pragma mark -
#pragma mark HFBrowserView Delegate
-(NSUInteger)numberOfPageInBrowserView:(HFBrowserView *)browser
{
    //返回多少项 <多少个页面>
    return 3;
}
-(UIView *)browserView:(HFBrowserView *)browser viewAtIndex:(NSUInteger)index
{
    if (index == 0) {

        HomeViewController *homeView = [[HomeViewController alloc]initWithNibName:nil bundle:nil];
        homeView.view.frame = browser.bounds;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, browser.bounds.size.height/2, browser.bounds.size.width, 30)];
        [self setApperanceForLabel:label1];
        label1.text = @"HomeView";
        [homeView.view addSubview:label1];
        return homeView.view;
    }else if (index == 1) {
        SeconedViewController *seconedView = [[SeconedViewController alloc]initWithNibName:nil bundle:nil];
        seconedView.view.frame = browser.bounds;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, browser.bounds.size.height/2, browser.bounds.size.width, 30)];
        [self setApperanceForLabel:label1];
        label1.text = @"seconedView";
        [seconedView.view addSubview:label1];
        return seconedView.view;
    }else {
        ThirdViewController *thirdView = [[ThirdViewController alloc]initWithNibName:nil bundle:nil];
        thirdView.view.frame = browser.bounds;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, browser.bounds.size.height/2, browser.bounds.size.width, 30)];
        [self setApperanceForLabel:label1];
        label1.text = @"thirdView";
        [thirdView.view addSubview:label1];
        return thirdView.view;
    }
}
//拖动调用后，滚动停止
-(void)browserViewlDidEndDecelerating:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    [self.segmentedControl setSelectedSegmentIndex:pageIndex animated:YES];
    [self refreshCurrentView];
}

//代码调用setContentOffset滚动停止
-(void)browserViewlDidEndScrollingAnimation:(HFBrowserView *)browser pageView:(UIView *)page pageIndex:(int)pageIndex
{
    //显示第几个视图了
    [self refreshCurrentView];
    
}

- (void)refreshCurrentView {
    UIView *pageView = [self.browserView getCurrentView];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
