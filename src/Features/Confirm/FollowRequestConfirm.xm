#import "../../Utils.h"

// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_onApproveButtonTapped)(id, SEL);
static void (*orig_onIgnoreButtonTapped)(id, SEL);

%hook IGPendingRequestView
- (void)_onApproveButtonTapped {
    if ([SCIUtils getBoolPref:@"follow_request_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow request triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_onApproveButtonTapped(selfCopy, cmdCopy);
        }];
    } else {
        %orig;
    }
}
- (void)_onIgnoreButtonTapped {
    if ([SCIUtils getBoolPref:@"follow_request_confirm"]) {
        NSLog(@"[SCInsta] Confirm follow request triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_onIgnoreButtonTapped(selfCopy, cmdCopy);
        }];
    } else {
        %orig;
    }
}
%end

%ctor {
    Class pendingRequestView = objc_getClass("IGPendingRequestView");
    if (pendingRequestView) {
        Method mApprove = class_getInstanceMethod(pendingRequestView, @selector(_onApproveButtonTapped));
        if (mApprove) orig_onApproveButtonTapped = (void (*)(id, SEL))method_getImplementation(mApprove);

        Method mIgnore = class_getInstanceMethod(pendingRequestView, @selector(_onIgnoreButtonTapped));
        if (mIgnore) orig_onIgnoreButtonTapped = (void (*)(id, SEL))method_getImplementation(mIgnore);
    }

    %init;
}