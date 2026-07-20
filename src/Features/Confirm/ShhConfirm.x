#import "../../Utils.h"

// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold)(id, SEL, id);
static void (*orig_shhModeTransitionButtonDidTap)(id, SEL, id);
static void (*orig_messageListViewControllerDidToggleShhMode)(id, SEL, id);

%hook IGDirectThreadViewController
- (void)swipeableScrollManagerDidEndDraggingAboveSwipeThreshold:(id)arg1 {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold(selfCopy, cmdCopy, arg1);
        }];
        return;
    }
    %orig;
}
- (void)shhModeTransitionButtonDidTap:(id)arg1 {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_shhModeTransitionButtonDidTap(selfCopy, cmdCopy, arg1);
        }];
        return;
    }
    %orig;
}
- (void)messageListViewControllerDidToggleShhMode:(id)arg1 {
    if ([SCIUtils getBoolPref:@"shh_mode_confirm"]) {
        NSLog(@"[SCInsta] Confirm shh mode triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_messageListViewControllerDidToggleShhMode(selfCopy, cmdCopy, arg1);
        }];
        return;
    }
    %orig;
}
%end

%ctor {
    Class threadVC = objc_getClass("IGDirectThreadViewController");
    if (threadVC) {
        Method mScroll = class_getInstanceMethod(threadVC, @selector(swipeableScrollManagerDidEndDraggingAboveSwipeThreshold:));
        if (mScroll) orig_swipeableScrollManagerDidEndDraggingAboveSwipeThreshold = (void (*)(id, SEL, id))method_getImplementation(mScroll);

        Method mButtonTap = class_getInstanceMethod(threadVC, @selector(shhModeTransitionButtonDidTap:));
        if (mButtonTap) orig_shhModeTransitionButtonDidTap = (void (*)(id, SEL, id))method_getImplementation(mButtonTap);

        Method mToggle = class_getInstanceMethod(threadVC, @selector(messageListViewControllerDidToggleShhMode:));
        if (mToggle) orig_messageListViewControllerDidToggleShhMode = (void (*)(id, SEL, id))method_getImplementation(mToggle);
    }

    %init;
}
