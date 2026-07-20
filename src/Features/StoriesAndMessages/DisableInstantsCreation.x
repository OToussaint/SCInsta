#import "../../Utils.h"

// Demangled name: IGQuickSnapExperimentation.IGQuickSnapExperimentationHelper
%hook _TtC26IGQuickSnapExperimentation32IGQuickSnapExperimentationHelper
+ (_Bool)isQuicksnapEnabled:(id)enabled {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(enabled);
}
+ (_Bool)isQuicksnapEnabledInFeed:(id)feed {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(feed);
}
+ (_Bool)isQuicksnapEnabledInInbox:(id)inbox {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(inbox);
}
+ (_Bool)isQuicksnapEnabledInStories:(id)stories {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(stories);
}
+ (_Bool)isQuicksnapEnabledInNotesTray:(id)tray {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(tray);
}
+ (_Bool)isQuicksnapEnabledInNotesTrayWithPeek:(id)peek {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(peek);
}
+ (_Bool)isQuicksnapEnabledInNotesTrayWithPog:(id)pog {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(pog);
}
+ (_Bool)isQuicksnapNotesTrayEmptyPogEnabled:(id)enabled {
    return [SCIUtils getBoolPref:@"disable_instants_creation"] ? false : %orig(enabled);
}
// + (_Bool)isStoriesSpringEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)shouldEnableScreenshotBlocking:(id)blocking {
//     return false;
// }
// + (_Bool)areFiltersEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)isBottomsheetCustomAudienceEnabled:(id)enabled {
//     return true;
// }
// + (_Bool)isVideoCaptureEnabled:(id)enabled {
//     return true;
// }
%end

// %hook IGDirectNotesTrayRowCell
// - (_Bool)isQuicksnapPeekVisible {
//     return true;
// }
// %end

// %hook IGDirectNotesTrayRowSectionController
// - (_Bool)isQuicksnapPeekVisible {
//     return true;
// }
// %end
