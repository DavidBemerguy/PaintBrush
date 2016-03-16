//
//  DrawTracker.m
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import "PaintTracker.h"

@implementation PaintTracker

-(id)copyWithZone:(NSZone *)zone
{
    PaintTracker *tracker = [[PaintTracker allocWithZone:zone] init];
    tracker.red = self.red;
    tracker.blue = self.blue;
    tracker.green = self.green;
    tracker.isErasing = self.isErasing;
    tracker.currentPoint = self.currentPoint;
    return tracker;
}

@end
