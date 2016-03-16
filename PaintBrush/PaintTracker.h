//
//  DrawTracker.h
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PaintTracker : NSObject <NSCopying>

@property(nonatomic, assign) CGFloat red;
@property(nonatomic, assign) CGFloat green;
@property(nonatomic, assign) CGFloat blue;
@property(nonatomic, assign) CGFloat brush;
@property(nonatomic, assign) BOOL isErasing;
@property(nonatomic, strong) NSMutableArray<NSValue *> *touchPoints;
@property(nonatomic, assign) NSUInteger order;

@end
