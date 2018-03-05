//
//  GCD.h
//  Marquee
//
//  Created by Lakhwinder Singh on 05/08/15.
//  Copyright (c) 2015 Impekable. All rights reserved.
//

@import Foundation;

#define dispatch_async_main_safely_variadic(block, ...) {if (block) {dispatch_async_main(^{block(__VA_ARGS__);});}}

#define ExecuteNullableBlockSafely(block, ...) {if (block) {block(__VA_ARGS__);}}

//! Shortcut for dispatch_async on main thread
void dispatch_async_main(dispatch_block_t block);

//! Shortcut for dispatch_async on default priority global queue
void dispatch_async_default(dispatch_block_t block);

//! Shortcut for dispatch_sync on main thread
void dispatch_sync_main(dispatch_block_t block);

//! Shortcut for dispatch_after on main thread
void dispatch_main_after(double delay, dispatch_block_t block);

//! Shortcut for dispatch_after on default priority queue
void dispatch_default_after(double delay, dispatch_block_t block);

//! Safely dispatches block to synchronous execution on main thread
void dispatch_sync_main_safely(dispatch_block_t block);

//! Shortcut for dispatch_group_async on main thread
void dispatch_group_async_main(dispatch_group_t group, dispatch_block_t block);

//! Shortcut for dispatch_group_async on global queue with default priority
void dispatch_group_async_default(dispatch_group_t group, dispatch_block_t block);

//! Shortcut for dispatch_group_wait with DISPATCH_TIME_FOREVER
void dispatch_group_wait_forever(dispatch_group_t group);

//! Shortcut for dispatch_group_notify on main thread
void dispatch_group_notify_main(dispatch_group_t group, dispatch_block_t block);

//! Shortcut for dispatch_time
dispatch_time_t dispatch_time_in_seconds(double delay);


