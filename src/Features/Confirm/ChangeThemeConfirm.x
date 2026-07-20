#import "../../InstagramHeaders.h"
#import "../../Utils.h"

// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot run *before* confirmation is granted, and
// cannot be reliably expanded inside a block nested in a message send.
static void (*orig_didSelectTheme)(id, SEL, id, id, NSInteger);
static void (*orig_didSelectThemeId)(id, SEL, id, id);
static void (*orig_primaryButtonTapped)(id, SEL);

%hook IGDirectThreadThemePickerViewController
- (void)themeNewPickerSectionController:(id)arg1 didSelectTheme:(id)arg2 atIndex:(NSInteger)arg3 {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didSelectTheme(selfCopy, cmdCopy, arg1, arg2, arg3);
        }];
        return;
    }
    %orig;
}
- (void)themePickerSectionController:(id)arg1 didSelectThemeId:(id)arg2 {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_didSelectThemeId(selfCopy, cmdCopy, arg1, arg2);
        }];
        return;
    }
    %orig;
}
%end

%hook IGDirectThreadThemeKitSwift.IGDirectThreadThemePreviewController
- (void)primaryButtonTapped {
    if ([SCIUtils getBoolPref:@"change_direct_theme_confirm"]) {
        NSLog(@"[SCInsta] Confirm change direct theme triggered");
        id selfCopy = self;
        SEL cmdCopy = _cmd;
        [SCIUtils showConfirmation:^(void) {
            orig_primaryButtonTapped(selfCopy, cmdCopy);
        }];
        return;
    }
    %orig;
}
%end

%ctor {
    Class themePicker = objc_getClass("IGDirectThreadThemePickerViewController");
    if (themePicker) {
        Method mSelectTheme = class_getInstanceMethod(themePicker, @selector(themeNewPickerSectionController:didSelectTheme:atIndex:));
        if (mSelectTheme) orig_didSelectTheme = (void (*)(id, SEL, id, id, NSInteger))method_getImplementation(mSelectTheme);

        Method mSelectThemeId = class_getInstanceMethod(themePicker, @selector(themePickerSectionController:didSelectThemeId:));
        if (mSelectThemeId) orig_didSelectThemeId = (void (*)(id, SEL, id, id))method_getImplementation(mSelectThemeId);
    }

    Class themePreview = objc_getClass("IGDirectThreadThemeKitSwift.IGDirectThreadThemePreviewController");
    if (themePreview) {
        Method mPrimaryTapped = class_getInstanceMethod(themePreview, @selector(primaryButtonTapped));
        if (mPrimaryTapped) orig_primaryButtonTapped = (void (*)(id, SEL))method_getImplementation(mPrimaryTapped);
    }

    %init;
}
