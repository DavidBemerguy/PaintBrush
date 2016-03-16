//
//  PaintTracker.h
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PaintTracker : NSObject <NSCopying>

@property(nonatomic, readonly) CGFloat red;
@property(nonatomic, readonly) CGFloat green;
@property(nonatomic, readonly) CGFloat blue;
@property(nonatomic, assign) CGFloat brush;
@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) BOOL isErasing;
@property(nonatomic, strong) NSMutableArray<NSValue *> *touchPoints;

@end
