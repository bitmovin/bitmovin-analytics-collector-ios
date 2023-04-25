//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AmazonIVSPlayer/IVSCue.h>

NS_ASSUME_NONNULL_BEGIN

/// Subtitles and captions, implemented as `IVSTextCue`.
IVS_EXPORT IVSCueType const IVSCueTypeText;

/// Possible values for `IVSTextCue.textAlignment`
typedef NS_ENUM(NSInteger, IVSTextCueAlignment) {
    /// Visually aligned to the start.
    IVSTextCueAlignmentStart,
    /// Visually aligned to the middle.
    IVSTextCueAlignmentMiddle,
    /// Visually aligned to the end.
    IVSTextCueAlignmentEnd,
} NS_SWIFT_NAME(IVSTextCue.Alignment);

/// Contains information for the display of subtitles and captions including styling and positioning.
/// Currently IVS streams do not contain positioning or styling information for TextCues.
/// TextCues should be rendered in accordance with user preferences for captions/subtitles and should
/// be cleared/reset when switching streams in the player or after a preset timeout period.
IVS_EXPORT
@interface IVSTextCue : IVSCue

/// Returns `IVSCueTypeText`.
@property (nonatomic, readonly) IVSCueType type;

/// Line positioning of the cue.
@property (nonatomic, readonly) float line;

/// Size of the cue as a percentage of video size, or zero if unspecified.
@property (nonatomic, readonly) float size;

/// Position of the text as a fraction of the cue box within the video.
@property (nonatomic, readonly) float position;

/// Text content of the cue.
@property (nonatomic, readonly) NSString *text;

/// Text alignment in the writing direction.
@property (nonatomic, readonly) IVSTextCueAlignment textAlignment;

@end

NS_ASSUME_NONNULL_END
