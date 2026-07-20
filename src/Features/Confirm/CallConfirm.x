#import "../../Utils.h"

// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_didTapAudioButton)(id, SEL, id);
static void (*orig_didTapVideoButton)(id, SEL, id);

%hook IGDirectThreadCallButtonsCoordinator
// Voice Call
- (void)_didTapAudioButton:(id)arg1 {
    if ([SCIUtils getBoolPref:@"call_confirm"]) {
        NSLog(@"[SCInsta] Call confirm triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didTapAudioButton(selfCopy, cmdCopy, arg1);
        }];
        return;
    }
    %orig;
}
// Video Call
- (void)_didTapVideoButton:(id)arg1 {
    if ([SCIUtils getBoolPref:@"call_confirm"]) {
        NSLog(@"[SCInsta] Call confirm triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didTapVideoButton(selfCopy, cmdCopy, arg1);
        }];
        return;
    }
    %orig;
}
%end

%ctor {
    Class callCoordinator = objc_getClass("IGDirectThreadCallButtonsCoordinator");
    if (callCoordinator) {
        Method mAudio = class_getInstanceMethod(callCoordinator, @selector(_didTapAudioButton:));
        if (mAudio) orig_didTapAudioButton = (void (*)(id, SEL, id))method_getImplementation(mAudio);

        Method mVideo = class_getInstanceMethod(callCoordinator, @selector(_didTapVideoButton:));
        if (mVideo) orig_didTapVideoButton = (void (*)(id, SEL, id))method_getImplementation(mVideo);
    }

    %init;
}
