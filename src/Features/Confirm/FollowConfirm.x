#import "../../Utils.h"
#import "../../InstagramHeaders.h"
////////////////////////////////////////////////////////
// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_didPressFollowButton)(id, SEL);
static void (*orig_onFollowButtonTapped)(id, SEL, id);
static void (*orig_onFollowingButtonTapped)(id, SEL, id);
static void (*orig_didTapAYMFActionButton)(id, SEL);
static void (*orig_didTapTextActionButton)(id, SEL);
static void (*orig_hackilyHandleOurOwnButtonTapsEvent)(id, SEL, id, id);
static void (*orig_navigationItemsControllerDidTapHeaderFollowButton)(id, SEL, id);
static void (*orig_followButtonTappedCell)(id, SEL, id, id);

// origFunc is one of the raw IMP pointers above; extra args (if any) are
// forwarded to it. Mirrors the original if/else CONFIRMFOLLOW shape, but
// calls the captured IMP directly instead of relying on %orig inside a block.
#define CONFIRMFOLLOW(origFunc, ...)                          \
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {           \
        NSLog(@"[SCInsta] Confirm follow triggered");         \
        id selfCopy = self;                                   \
        SEL cmdCopy = _cmd;                                   \
        [SCIUtils showConfirmation:^(void) {                  \
            origFunc(selfCopy, cmdCopy, ##__VA_ARGS__);        \
        }];                                                   \
    }                                                          \
    else {                                                     \
        %orig;                                                 \
    }
////////////////////////////////////////////////////////
// Follow button on profile page
%hook IGFollowController
- (void)_didPressFollowButton {
    // Get user follow status (check if already following user)
    NSInteger UserFollowStatus = self.user.followStatus;
    // Only show confirm dialog if user is not following
    if (UserFollowStatus == 2) {
        CONFIRMFOLLOW(orig_didPressFollowButton);
    }
    else {
        %orig;
    }
}
%end
// Follow button on discover people page
%hook IGDiscoverPeopleButtonGroupView
- (void)_onFollowButtonTapped:(id)arg1 {
    CONFIRMFOLLOW(orig_onFollowButtonTapped, arg1);
}
- (void)_onFollowingButtonTapped:(id)arg1 {
    CONFIRMFOLLOW(orig_onFollowingButtonTapped, arg1);
}
%end
// Suggested for you (home feed & profile) follow button
%hook IGHScrollAYMFCell
- (void)_didTapAYMFActionButton {
    CONFIRMFOLLOW(orig_didTapAYMFActionButton);
}
%end
%hook IGHScrollAYMFActionButton
- (void)_didTapTextActionButton {
    CONFIRMFOLLOW(orig_didTapTextActionButton);
}
%end
// Follow button on reels
%hook IGUnifiedVideoFollowButton
- (void)_hackilyHandleOurOwnButtonTaps:(id)arg1 event:(id)arg2 {
    CONFIRMFOLLOW(orig_hackilyHandleOurOwnButtonTapsEvent, arg1, arg2);
}
%end
// Follow text on profile (when collapsed into top bar)
%hook IGProfileViewController
- (void)navigationItemsControllerDidTapHeaderFollowButton:(id)arg1 {
    CONFIRMFOLLOW(orig_navigationItemsControllerDidTapHeaderFollowButton, arg1);
}
%end
// Follow button on suggested friends (in story section)
%hook IGStorySectionController
- (void)followButtonTapped:(id)arg1 cell:(id)arg2 {
    CONFIRMFOLLOW(orig_followButtonTappedCell, arg1, arg2);
}
%end
// Follow all button in group chats (3+ members) people view
static void (*orig_listSectionController)(id, SEL, id, id);
static void hooked_listSectionController(id self, SEL _cmd, id arg1, id arg2) {
    if ([SCIUtils getBoolPref:@"follow_confirm"]) {
        [SCIUtils showConfirmation:^{
            orig_listSectionController(self, _cmd, arg1, arg2);
        }];
        return;
    }
    orig_listSectionController(self, _cmd, arg1, arg2);
}

%ctor {
    Class followController = objc_getClass("IGFollowController");
    if (followController) {
        Method m = class_getInstanceMethod(followController, @selector(_didPressFollowButton));
        if (m) orig_didPressFollowButton = (void (*)(id, SEL))method_getImplementation(m);
    }

    Class discoverGroupView = objc_getClass("IGDiscoverPeopleButtonGroupView");
    if (discoverGroupView) {
        Method mFollow = class_getInstanceMethod(discoverGroupView, @selector(_onFollowButtonTapped:));
        if (mFollow) orig_onFollowButtonTapped = (void (*)(id, SEL, id))method_getImplementation(mFollow);

        Method mFollowing = class_getInstanceMethod(discoverGroupView, @selector(_onFollowingButtonTapped:));
        if (mFollowing) orig_onFollowingButtonTapped = (void (*)(id, SEL, id))method_getImplementation(mFollowing);
    }

    Class aymfCell = objc_getClass("IGHScrollAYMFCell");
    if (aymfCell) {
        Method m = class_getInstanceMethod(aymfCell, @selector(_didTapAYMFActionButton));
        if (m) orig_didTapAYMFActionButton = (void (*)(id, SEL))method_getImplementation(m);
    }

    Class aymfActionButton = objc_getClass("IGHScrollAYMFActionButton");
    if (aymfActionButton) {
        Method m = class_getInstanceMethod(aymfActionButton, @selector(_didTapTextActionButton));
        if (m) orig_didTapTextActionButton = (void (*)(id, SEL))method_getImplementation(m);
    }

    Class videoFollowButton = objc_getClass("IGUnifiedVideoFollowButton");
    if (videoFollowButton) {
        Method m = class_getInstanceMethod(videoFollowButton, @selector(_hackilyHandleOurOwnButtonTaps:event:));
        if (m) orig_hackilyHandleOurOwnButtonTapsEvent = (void (*)(id, SEL, id, id))method_getImplementation(m);
    }

    Class profileVC = objc_getClass("IGProfileViewController");
    if (profileVC) {
        Method m = class_getInstanceMethod(profileVC, @selector(navigationItemsControllerDidTapHeaderFollowButton:));
        if (m) orig_navigationItemsControllerDidTapHeaderFollowButton = (void (*)(id, SEL, id))method_getImplementation(m);
    }

    Class storySectionController = objc_getClass("IGStorySectionController");
    if (storySectionController) {
        Method m = class_getInstanceMethod(storySectionController, @selector(followButtonTapped:cell:));
        if (m) orig_followButtonTappedCell = (void (*)(id, SEL, id, id))method_getImplementation(m);
    }

    Class membersListVC = objc_getClass("IGDirectDetailMembersKit.IGDirectThreadDetailsMembersListViewController");
    if (membersListVC) {
        MSHookMessageEx(
            membersListVC,
            @selector(listSectionController:didTapHeaderButtonWithViewModel:),
            (IMP)hooked_listSectionController,
            (IMP *)&orig_listSectionController
        );
    }

    %init;
}
