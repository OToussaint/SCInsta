#import "../../Utils.h"

// Raw original IMP captured before Logos swizzles it.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_didTap)(id, SEL, id, id);

%hook IGStoryViewerTapTarget
- (void)_didTap:(id)arg1 forEvent:(id)arg2 {
    if ([SCIUtils getBoolPref:@"sticker_interact_confirm"]) {
        NSLog(@"[SCInsta] Confirm sticker interact triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didTap(selfCopy, cmdCopy, arg1, arg2);
        }];
    } else {
        %orig;
    }
}
%end

%ctor {
    Class tapTarget = objc_getClass("IGStoryViewerTapTarget");
    if (tapTarget) {
        Method m = class_getInstanceMethod(tapTarget, @selector(_didTap:forEvent:));
        if (m) orig_didTap = (void (*)(id, SEL, id, id))method_getImplementation(m);
    }

    %init;
}