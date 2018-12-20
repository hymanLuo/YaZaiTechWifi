//
//  UIView+Frame.h
//  YaZai
//
//  Created by admin on 2018/11/24.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (assign, nonatomic) CGFloat   top;
@property (assign, nonatomic) CGFloat   bottom;
@property (assign, nonatomic) CGFloat   left;
@property (assign, nonatomic) CGFloat   right;

@property (assign, nonatomic) CGFloat   x;
@property (assign, nonatomic) CGFloat   y;
@property (assign, nonatomic) CGPoint   origin;

@property (assign, nonatomic) CGFloat   centerX;
@property (assign, nonatomic) CGFloat   centerY;

@property (assign, nonatomic) CGFloat   width;
@property (assign, nonatomic) CGFloat   height;
@property (assign, nonatomic) CGSize    size;

@end
