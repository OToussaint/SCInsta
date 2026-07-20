#import "../../Utils.h"

// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_didRecordAudioClip)(id, SEL, id, id, id, CGFloat, NSInteger);
static void (*orig_didTapSend)(id, SEL);

// Legacy hook (for non ai voices interface)
%hook IGDirectThreadViewController
- (void)voiceRecordViewController:(id)arg1 didRecordAudioClipWithURL:(id)arg2 waveform:(id)arg3 duration:(CGFloat)arg4 entryPoint:(NSInteger)arg5 {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        NSLog(@"[SCInsta] DM audio message confirm triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didRecordAudioClip(selfCopy, cmdCopy, arg1, arg2, arg3, arg4, arg5);
        }];
        return;
    }
    %orig;
}
%end
// Workaround until I can figure out how to stop long press recording from automatically sending
%hook IGDirectComposer
- (void)_didLongPressVoiceMessage:(id)arg1 {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        return;
    } else {
        return %orig;
    }
}
%end
// Demangled name: IGDirectAIVoiceUIKit.CompactBarContentView
%hook _TtC20IGDirectAIVoiceUIKitP33_5754F7617E0D924F9A84EFA352BBD29A21CompactBarContentView
- (void)didTapSend {
    if ([SCIUtils getBoolPref:@"voice_message_confirm"]) {
        NSLog(@"[SCInsta] DM audio message confirm triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didTapSend(selfCopy, cmdCopy);
        }];
        return;
    }
    %orig;
}
%end

%ctor {
    Class threadVC = objc_getClass("IGDirectThreadViewController");
    if (threadVC) {
        Method mRecord = class_getInstanceMethod(threadVC, @selector(voiceRecordViewController:didRecordAudioClipWithURL:waveform:duration:entryPoint:));
        if (mRecord) orig_didRecordAudioClip = (void (*)(id, SEL, id, id, id, CGFloat, NSInteger))method_getImplementation(mRecord);
    }

    Class compactBar = objc_getClass("_TtC20IGDirectAIVoiceUIKitP33_5754F7617E0D924F9A84EFA352BBD29A21CompactBarContentView");
    if (compactBar) {
        Method mSend = class_getInstanceMethod(compactBar, @selector(didTapSend));
        if (mSend) orig_didTapSend = (void (*)(id, SEL))method_getImplementation(mSend);
    }

    %init;
}
