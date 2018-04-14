//
//  PassthroughView.m
//  Weez
//
//  Created by Molham on 9/23/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "PassthroughView.h"


@implementation PassthroughView
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}
@end

