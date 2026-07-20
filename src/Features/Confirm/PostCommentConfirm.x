#import "../../Utils.h"

// Raw original IMP captured before Logos swizzles it.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_onSendButtonTap)(id, SEL);

%hook IGCommentComposer.IGCommentComposerController
- (void)onSendButtonTap {
    if ([SCIUtils getBoolPref:@"post_comment_confirm"]) {
        NSLog(@"[SCInsta] Confirm post comment triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_onSendButtonTap(selfCopy, cmdCopy);
        }];
        return;
    }
    %orig;
}
%end

%ctor {
    Class commentComposer = objc_getClass("IGCommentComposer.IGCommentComposerController");
    if (commentComposer) {
        Method mSend = class_getInstanceMethod(commentComposer, @selector(onSendButtonTap));
        if (mSend) orig_onSendButtonTap = (void (*)(id, SEL))method_getImplementation(mSend);
    }

    %init;
}
