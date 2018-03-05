//
//  GCD.m
//  Marquee
//
//  Created by Lakhwinder Singh on 05/08/15.
//  Copyright (c) 2015 Impekable. All rights reserved.
//

#import "GCD.h"

void dispatch_async_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_async_default(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void dispatch_sync_main(dispatch_block_t block) {
    dispatch_sync(dispatch_get_main_queue(), block);
}

void dispatch_main_after(double delay, dispatch_block_t block) {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), block);
}

void dispatch_default_after(double delay, dispatch_block_t block) {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void dispatch_sync_main_safely(dispatch_block_t block) {
    if (block) {
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_sync_main(block);
        }
    }
}

void dispatch_group_async_main(dispatch_group_t group, dispatch_block_t block) {
    dispatch_group_async(group, dispatch_get_main_queue(), block);
}

void dispatch_group_async_default(dispatch_group_t group, dispatch_block_t block) {
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void dispatch_group_wait_forever(dispatch_group_t group) {
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

void dispatch_group_notify_main(dispatch_group_t group, dispatch_block_t block) {
    dispatch_group_notify(group, dispatch_get_main_queue(), block);
}

dispatch_time_t dispatch_time_in_seconds(double delay) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
}


