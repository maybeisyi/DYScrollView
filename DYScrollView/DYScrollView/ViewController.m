//
//  ViewController.m
//  滚动图片
//
//  Created by daiyi on 2016/10/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "ViewController.h"

typedef NS_ENUM(NSInteger, ScrollDirection) {
    ScrollDirectionUnknow,
    ScrollDirectionLeft,
    ScrollDirectionRight
};

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
/** 显示用的imageView */
@property (nonatomic, strong) UIImageView *currentImageView;
/** 滚动的时候被“滚出来”的imageView */
@property (nonatomic, strong) UIImageView *otherImageView;
/** 当前显示第几张图片 */
@property (nonatomic, assign) NSInteger currentPage;
/** 所有图片数组 */
@property (nonatomic, strong) NSArray<UIImage *> *imageArr;
/** 滚动方向 */
@property (nonatomic, assign) ScrollDirection scrollDirection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollDirection = ScrollDirectionUnknow;
    
    // 初始化一下所有要显示图片
    _imageArr = @[[UIImage imageNamed:@"background-0"],[UIImage imageNamed:@"background-1"],[UIImage imageNamed:@"background-2"],[UIImage imageNamed:@"background-3"],[UIImage imageNamed:@"background-4"]];
    
    // 初始化一下scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 250)];
    // 滚动范围 X轴为 >= 3，才能实现左右都能滚动
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 250);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    // 一开始，显示第0张图片
    _currentPage = 0;
    
    // 当前图片，一开始就需要显示的，并且显示在整个contentSize范围的中间。这样左右均可滚动
    _currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 250)];
    _currentImageView.image = _imageArr[_currentPage];
    [_scrollView addSubview:_currentImageView];
    
    // 初始化，位置别和_currentImageView重了即可
    _otherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
    [_scrollView addSubview:_otherImageView];
    
    // 永远都显示中间的区域，而_currentImageView永远在中间，也就意味着永远显示_currentImageView
    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
}

#pragma mark - UIScrollViewDelegate代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /** 判断一下此时是向右滚动还是向左滚动，根据设想，停止时的scrollView显示的内容永远是中间，那么scrollView.contentOffset.x 应该永远是 scrollView.frame.size.width，这里就是SCREEN_WIDTH。那么在动的时候通过scrollView.contentOffset.x 就可以知道是向哪个方向滚动
     
     性能优化：1. 该方法在滚动过程中重复调用，向左向右滑动其实在改变时赋值即可，后续无需判断？  ——>利用self.scrollDirection进方向判断来优化操作次数
     2._otherImageView 反复调用 setFrame 和 setImage 方法，是否会有损性能？ ——>利用self.scrollDirection进方向判断来优化操作次数
     */
    
    
    if (scrollView.contentOffset.x > SCREEN_WIDTH) {
        
        if (self.scrollDirection == ScrollDirectionUnknow || self.scrollDirection == ScrollDirectionLeft) {
            NSLog(@"向右滚动");
            
            // 向右滚动则要把另一张图片放在右边
            _otherImageView.frame = CGRectMake(_currentImageView.frame.origin.x + SCREEN_WIDTH, 0, SCREEN_WIDTH, 250);
            
            // 同时给这个imageView上图片
            if (_currentPage == _imageArr.count - 1) {
                _otherImageView.image = _imageArr[0];
            } else {
                _otherImageView.image = _imageArr[_currentPage + 1];
            }
            
            self.scrollDirection = ScrollDirectionRight;
        }
    } else if (scrollView.contentOffset.x < SCREEN_WIDTH) {
        
        if (self.scrollDirection == ScrollDirectionUnknow || self.scrollDirection == ScrollDirectionRight) {
            NSLog(@"向左滚动");

            // 同理向左
            _otherImageView.frame = CGRectMake(_currentImageView.frame.origin.x - SCREEN_WIDTH, 0, SCREEN_WIDTH, 250);
            if (_currentPage == 0) {
                _otherImageView.image = _imageArr[_imageArr.count - 1];
            } else {
                _otherImageView.image = _imageArr[_currentPage - 1];
            }
            
            self.scrollDirection = ScrollDirectionLeft;
        }
    } else {
        self.scrollDirection = ScrollDirectionUnknow;
    }
    
    // 重置图像，就是把otherImageView拉到中间全部显示的时候，赶紧换currentImageView来显示，即把scrollView.contentOffset.x 又设置到原来的位置，那么_currentImageView又能够全部显示了，但是_currentImageView显示的上一张/下一张的图片，需要替换成当前图片。进入该判断次数不多
    if (scrollView.contentOffset.x >= SCREEN_WIDTH * 2) {
        NSLog(@"向右越界");
        if (_currentPage == 4) {
            _currentPage = 0;
        } else {
            _currentPage++;
        }
        _currentImageView.image = _imageArr[_currentPage];
        scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        
    } else if (scrollView.contentOffset.x <= 0) {
        NSLog(@"向左越界");
        if (_currentPage == 0) {
            _currentPage = 4;
        } else {
            _currentPage--;
        }
        _currentImageView.image = _imageArr[_currentPage];
        scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        
    }
}

@end
