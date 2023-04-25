//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AmazonIVSPlayer/IVSCue.h>

NS_ASSUME_NONNULL_BEGIN

/// Plaintext timed metadata, implemented as `IVSTextMetadataCue`.
IVS_EXPORT IVSCueType const IVSCueTypeTextMetadata;

/// Metadata injected out of band via the AWS HTTP API
IVS_EXPORT NSString * const IVSCueID3MetadataID;

/// Metadata injected into the RTMP connection by the broadcaster directly
IVS_EXPORT NSString * const IVSCueInbandID3MetadataID;

/// Plaintext timed metdatada cue.
IVS_EXPORT
@interface IVSTextMetadataCue : IVSCue

/// Returns `IVSCueTypeTextMetadata`.
@property (nonatomic, readonly) IVSCueType type;

/// Text content of the cue.
@property (nonatomic, readonly) NSString *text;

/// Description of the text content.
@property (nonatomic, readonly) NSString *textDescription;

/// Source of the text content, either inband RTMP (IVSCueInbandID3MetadataID)
/// or out of band HTTP IVS API (IVSCueID3MetadataID)
@property (nonatomic, readonly) NSString *textOwner;

@end

NS_ASSUME_NONNULL_END
