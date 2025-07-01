[UISS#refreshViews]
- (void)refreshViews {
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSWillRefreshViewsNotification object:self];
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSDidRefreshViewsNotification object:self];
}
[UISS#refreshViews]: https://github.com/robertwijas/UISS/blob/8f2412b2dda19aa945c201b65dd7b777441c38ab/Project/UISS/UISS.m#L177
