#import "../../Utils.h"

////////////////////////////////////////////////////////
// Raw original IMPs captured before Logos swizzles them.
// Needed because %orig cannot be reliably expanded inside a block that is
// itself nested inside a message send argument.
static void (*orig_ufiBarOnLikePressed)(id, SEL, id);
static void (*orig_feedPhotoOnDoubleTap)(id, SEL, id);
static void (*orig_videoPlayerHandleDoubleTap)(id, SEL, id);
static void (*orig_videoCellDidTapLike)(id, SEL, id);
static void (*orig_videoCellDidLongPressLike)(id, SEL, id, id);
static void (*orig_videoCellGestureDoubleTap)(id, SEL, id, id);
static void (*orig_photoCellDidTapLike)(id, SEL, id);
static void (*orig_photoCellGestureDoubleTap)(id, SEL, id, id);
static void (*orig_carouselCellDidTapLike)(id, SEL, id);
static void (*orig_carouselCellGestureDoubleTap)(id, SEL, id, id);
static void (*orig_commentCellDidTapLike)(id, SEL, id, id);
static void (*orig_commentCellDidTapLikedBy)(id, SEL, id, id);
static void (*orig_commentCellDidLongPressLike)(id, SEL, id);
static void (*orig_commentCellDidEndLongPressLike)(id, SEL, id);
static void (*orig_commentCellDidDoubleTap)(id, SEL, id);
static void (*orig_feedItemPreviewDidTapLike)(id, SEL);
static void (*orig_handleLikeTapped)(id, SEL);
static void (*orig_likeTapped)(id, SEL);
static void (*orig_inputViewDidTapLike)(id, SEL, id, id);
static void (*orig_directThreadDidTapLike)(id, SEL);

// origFunc is one of the raw IMP pointers above; extra args (if any) are
// forwarded to it. Mirrors the original if/else confirm shape, but
// calls the captured IMP directly instead of relying on %orig inside a block.
#define CONFIRMPOSTLIKE(origFunc, ...)                            \
    if ([SCIUtils getBoolPref:@"like_confirm"]) {                  \
        NSLog(@"[SCInsta] Confirm post like triggered");          \
        id selfCopy = self;                                       \
        SEL cmdCopy = _cmd;                                       \
        [SCIUtils showConfirmation:^(void) {                      \
            origFunc(selfCopy, cmdCopy, ##__VA_ARGS__);            \
        }];                                                       \
    }                                                             \
    else {                                                        \
        %orig;                                                    \
    }

#define CONFIRMREELSLIKE(origFunc, ...)                           \
    if ([SCIUtils getBoolPref:@"like_confirm_reels"]) {            \
        NSLog(@"[SCInsta] Confirm reels like triggered");         \
        id selfCopy = self;                                       \
        SEL cmdCopy = _cmd;                                       \
        [SCIUtils showConfirmation:^(void) {                      \
            origFunc(selfCopy, cmdCopy, ##__VA_ARGS__);            \
        }];                                                       \
    }                                                             \
    else {                                                        \
        %orig;                                                    \
    }

///////////////////////////////////////////////////////////

// Liking posts
%hook IGUFIButtonBarView
- (void)_onLikeButtonPressed:(id)arg1 {
    CONFIRMPOSTLIKE(orig_ufiBarOnLikePressed, arg1);
}
%end
%hook IGFeedPhotoView
- (void)_onDoubleTap:(id)arg1 {
    CONFIRMPOSTLIKE(orig_feedPhotoOnDoubleTap, arg1);
}
%end
%hook IGVideoPlayerOverlayContainerView
- (void)_handleDoubleTapGesture:(id)arg1 {
    CONFIRMPOSTLIKE(orig_videoPlayerHandleDoubleTap, arg1);
}
%end

// Liking reels
%hook IGSundialViewerVideoCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(orig_videoCellDidTapLike, arg1);
}
- (void)controlsOverlayControllerDidLongPressLikeButton:(id)arg1 gestureRecognizer:(id)arg2 {
    CONFIRMREELSLIKE(orig_videoCellDidLongPressLike, arg1, arg2);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(orig_videoCellGestureDoubleTap, arg1, arg2);
}
%end
%hook IGSundialViewerPhotoCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(orig_photoCellDidTapLike, arg1);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(orig_photoCellGestureDoubleTap, arg1, arg2);
}
%end
%hook IGSundialViewerCarouselCell
- (void)controlsOverlayControllerDidTapLikeButton:(id)arg1 {
    CONFIRMREELSLIKE(orig_carouselCellDidTapLike, arg1);
}
- (void)gestureController:(id)arg1 didObserveDoubleTap:(id)arg2 {
    CONFIRMREELSLIKE(orig_carouselCellGestureDoubleTap, arg1, arg2);
}
%end

// Liking comments
%hook IGCommentCellController
- (void)commentCell:(id)arg1 didTapLikeButton:(id)arg2 {
    CONFIRMPOSTLIKE(orig_commentCellDidTapLike, arg1, arg2);
}
- (void)commentCell:(id)arg1 didTapLikedByButtonForUser:(id)arg2 {
    CONFIRMPOSTLIKE(orig_commentCellDidTapLikedBy, arg1, arg2);
}
- (void)commentCellDidLongPressOnLikeButton:(id)arg1 {
    CONFIRMPOSTLIKE(orig_commentCellDidLongPressLike, arg1);
}
- (void)commentCellDidEndLongPressOnLikeButton:(id)arg1 {
    CONFIRMPOSTLIKE(orig_commentCellDidEndLongPressLike, arg1);
}
- (void)commentCellDidDoubleTap:(id)arg1 {
    CONFIRMPOSTLIKE(orig_commentCellDidDoubleTap, arg1);
}
%end
%hook IGFeedItemPreviewCommentCell
- (void)_didTapLikeButton {
    CONFIRMPOSTLIKE(orig_feedItemPreviewDidTapLike);
}
%end

// Liking stories
%hook IGStoryFullscreenDefaultFooterView
- (void)_handleLikeTapped {
    CONFIRMPOSTLIKE(orig_handleLikeTapped);
}
- (void)_likeTapped {
    CONFIRMPOSTLIKE(orig_likeTapped);
}
- (void)inputView:(id)arg1 didTapLikeButton:(id)arg2 {
    CONFIRMPOSTLIKE(orig_inputViewDidTapLike, arg1, arg2);
}

// For some stupid reason they removed the "liketapped" methods on newer Instagram versions
// Now we have to do a shitty workaround instead :(
// Works 99% of the time, but sometimes clicks get through directly to the like button (somehow)
- (void)layoutSubviews {
    %orig;

    if (![SCIUtils getBoolPref:@"like_confirm"]) return;

    UIButton *likeButton = [self valueForKey:@"likeButton"];
    if (!likeButton) return;

    // 129115 = L(12) I(9) K(11) E(5)
    static NSInteger kOverlayTag = 129115;
    if ([likeButton viewWithTag:kOverlayTag]) return;

    UIButton *overlay = [UIButton buttonWithType:UIButtonTypeCustom];
    overlay.tag = kOverlayTag;
    overlay.frame = likeButton.bounds;
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [overlay addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
    [likeButton addSubview:overlay];
}

%new - (void)overlayTapped:(UIButton *)overlay {
    UIButton *likeButton = (UIButton *)overlay.superview;

    [SCIUtils showConfirmation:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [likeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
    }];
}
%end

// DM like button (seems to be hidden)
%hook IGDirectThreadViewController
- (void)_didTapLikeButton {
    CONFIRMPOSTLIKE(orig_directThreadDidTapLike);
}
%end

%ctor {
    Class ufiBar = objc_getClass("IGUFIButtonBarView");
    if (ufiBar) {
        Method m = class_getInstanceMethod(ufiBar, @selector(_onLikeButtonPressed:));
        if (m) orig_ufiBarOnLikePressed = (void (*)(id, SEL, id))method_getImplementation(m);
    }

    Class feedPhoto = objc_getClass("IGFeedPhotoView");
    if (feedPhoto) {
        Method m = class_getInstanceMethod(feedPhoto, @selector(_onDoubleTap:));
        if (m) orig_feedPhotoOnDoubleTap = (void (*)(id, SEL, id))method_getImplementation(m);
    }

    Class videoOverlay = objc_getClass("IGVideoPlayerOverlayContainerView");
    if (videoOverlay) {
        Method m = class_getInstanceMethod(videoOverlay, @selector(_handleDoubleTapGesture:));
        if (m) orig_videoPlayerHandleDoubleTap = (void (*)(id, SEL, id))method_getImplementation(m);
    }

    Class videoCell = objc_getClass("IGSundialViewerVideoCell");
    if (videoCell) {
        Method mTap = class_getInstanceMethod(videoCell, @selector(controlsOverlayControllerDidTapLikeButton:));
        if (mTap) orig_videoCellDidTapLike = (void (*)(id, SEL, id))method_getImplementation(mTap);

        Method mLongPress = class_getInstanceMethod(videoCell, @selector(controlsOverlayControllerDidLongPressLikeButton:gestureRecognizer:));
        if (mLongPress) orig_videoCellDidLongPressLike = (void (*)(id, SEL, id, id))method_getImplementation(mLongPress);

        Method mDoubleTap = class_getInstanceMethod(videoCell, @selector(gestureController:didObserveDoubleTap:));
        if (mDoubleTap) orig_videoCellGestureDoubleTap = (void (*)(id, SEL, id, id))method_getImplementation(mDoubleTap);
    }

    Class photoCell = objc_getClass("IGSundialViewerPhotoCell");
    if (photoCell) {
        Method mTap = class_getInstanceMethod(photoCell, @selector(controlsOverlayControllerDidTapLikeButton:));
        if (mTap) orig_photoCellDidTapLike = (void (*)(id, SEL, id))method_getImplementation(mTap);

        Method mDoubleTap = class_getInstanceMethod(photoCell, @selector(gestureController:didObserveDoubleTap:));
        if (mDoubleTap) orig_photoCellGestureDoubleTap = (void (*)(id, SEL, id, id))method_getImplementation(mDoubleTap);
    }

    Class carouselCell = objc_getClass("IGSundialViewerCarouselCell");
    if (carouselCell) {
        Method mTap = class_getInstanceMethod(carouselCell, @selector(controlsOverlayControllerDidTapLikeButton:));
        if (mTap) orig_carouselCellDidTapLike = (void (*)(id, SEL, id))method_getImplementation(mTap);

        Method mDoubleTap = class_getInstanceMethod(carouselCell, @selector(gestureController:didObserveDoubleTap:));
        if (mDoubleTap) orig_carouselCellGestureDoubleTap = (void (*)(id, SEL, id, id))method_getImplementation(mDoubleTap);
    }

    Class commentCell = objc_getClass("IGCommentCellController");
    if (commentCell) {
        Method mTapLike = class_getInstanceMethod(commentCell, @selector(commentCell:didTapLikeButton:));
        if (mTapLike) orig_commentCellDidTapLike = (void (*)(id, SEL, id, id))method_getImplementation(mTapLike);

        Method mTapLikedBy = class_getInstanceMethod(commentCell, @selector(commentCell:didTapLikedByButtonForUser:));
        if (mTapLikedBy) orig_commentCellDidTapLikedBy = (void (*)(id, SEL, id, id))method_getImplementation(mTapLikedBy);

        Method mLongPress = class_getInstanceMethod(commentCell, @selector(commentCellDidLongPressOnLikeButton:));
        if (mLongPress) orig_commentCellDidLongPressLike = (void (*)(id, SEL, id))method_getImplementation(mLongPress);

        Method mEndLongPress = class_getInstanceMethod(commentCell, @selector(commentCellDidEndLongPressOnLikeButton:));
        if (mEndLongPress) orig_commentCellDidEndLongPressLike = (void (*)(id, SEL, id))method_getImplementation(mEndLongPress);

        Method mDoubleTap = class_getInstanceMethod(commentCell, @selector(commentCellDidDoubleTap:));
        if (mDoubleTap) orig_commentCellDidDoubleTap = (void (*)(id, SEL, id))method_getImplementation(mDoubleTap);
    }

    Class feedItemPreview = objc_getClass("IGFeedItemPreviewCommentCell");
    if (feedItemPreview) {
        Method m = class_getInstanceMethod(feedItemPreview, @selector(_didTapLikeButton));
        if (m) orig_feedItemPreviewDidTapLike = (void (*)(id, SEL))method_getImplementation(m);
    }

    Class storyFooter = objc_getClass("IGStoryFullscreenDefaultFooterView");
    if (storyFooter) {
        Method mHandle = class_getInstanceMethod(storyFooter, @selector(_handleLikeTapped));
        if (mHandle) orig_handleLikeTapped = (void (*)(id, SEL))method_getImplementation(mHandle);

        Method mLike = class_getInstanceMethod(storyFooter, @selector(_likeTapped));
        if (mLike) orig_likeTapped = (void (*)(id, SEL))method_getImplementation(mLike);

        Method mInputView = class_getInstanceMethod(storyFooter, @selector(inputView:didTapLikeButton:));
        if (mInputView) orig_inputViewDidTapLike = (void (*)(id, SEL, id, id))method_getImplementation(mInputView);
    }

    Class directThread = objc_getClass("IGDirectThreadViewController");
    if (directThread) {
        Method m = class_getInstanceMethod(directThread, @selector(_didTapLikeButton));
        if (m) orig_directThreadDidTapLike = (void (*)(id, SEL))method_getImplementation(m);
    }

    %init;
}