window.bitmovin = window.bitmovin || {};
window.bitmovin.player = window.bitmovin.player || {};
window.bitmovin.player.EVENT = window.bitmovin.player.EVENT || {};
window.bitmovin.player.EVENT = {
    /**
     * Is fired when the player is initialized and ready to play and to handle API calls.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_READY constant.
     *
     * @event
     * @since v4.0
     */
    ON_READY: 'onReady',

    /**
     * Is fired when the player enters the play state.
     * The passed event is of type {@link PlaybackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PLAY constant.
     *
     * @event
     * @since v4.0
     */
    ON_PLAY: 'onPlay',

    /**
     * Is fired when the player actually has started playback.
     * The passed event is of type {@PlaybackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PLAYING constant.
     *
     * @event
     * @instance
     * @since v7.3
     */
    ON_PLAYING: 'onPlaying',

    /**
     * Is fired when the player enters the pause state.
     * The passed event is of type {@link PlaybackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PAUSED constant.
     *
     * In previous player versions, this was called ON_PAUSE.
     *
     * @event
     * @since v7.0
     */
    ON_PAUSED: 'onPaused',

    /**
     * Is fired periodically during seeking. Only applies to VoD streams, please refer to onTimeShift for live.
     * The passed event is of type {@link SeekEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SEEK constant.
     *
     * @event
     * @since v4.0
     */
    ON_SEEK: 'onSeek',

    /**
     * Is fired when seeking has been finished and data is available to continue playback. Only applies to VoD streams,
     * please refer to onTimeShifted for live.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SEEKED constant.
     *
     * @event
     * @since v4.0
     */
    ON_SEEKED: 'onSeeked',

    /**
     * Is fired periodically during time shifting. Only applies to live streams, please refer to onSeek for VoD.
     * The passed event is of type {@link TimeShiftEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_TIME_SHIFT constant.
     *
     * @event
     * @since v5.0
     */
    ON_TIME_SHIFT: 'onTimeShift',

    /**
     * Is fired when time shifting has been finished and data is available to continue playback. Only applies to live
     * streams, please refer to onSeeked for VoD.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_TIME_SHIFTED constant.
     *
     * @event
     * @since v5.0
     */
    ON_TIME_SHIFTED: 'onTimeShifted',

    /**
     * Is fired when the volume is changed.
     * The passed event is of type {@link VolumeChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VOLUME_CHANGED constant.
     *
     * In previous player versions, this was called ON_VOLUME_CHANGE.
     *
     * @event
     * @since v7.0
     */
    ON_VOLUME_CHANGED: 'onVolumeChanged',

    /**
     * Is fired when the player is muted.
     * The passed event is of type {@link UserInteractionEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_MUTED constant.
     *
     * In previous player versions, this was called ON_MUTE.
     *
     * @event
     * @since v7.0
     */
    ON_MUTED: 'onMuted',

    /**
     * Is fired when the player is unmuted.
     * The passed event is of type {@link UserInteractionEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_UNMUTED constant.
     *
     * In previous player versions, this was called ON_UNMUTE.
     *
     * @event
     * @since v7.0
     */
    ON_UNMUTED: 'onUnmuted',

    /**
     * Is fired when the player enters fullscreen mode.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_FULLSCREEN_ENTER constant.
     *
     * @event
     * @since v4.0
     */
    ON_FULLSCREEN_ENTER: 'onFullscreenEnter',

    /**
     * Is fired when the player exits fullscreen mode.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_FULLSCREEN_EXIT constant.
     *
     * @event
     * @since v4.0
     */
    ON_FULLSCREEN_EXIT: 'onFullscreenExit',

    /**
     * Is fired when the player size is updated.
     * The passed event is of type {@link PlayerResizeEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PLAYER_RESIZE constant.
     *
     * @event
     * @since v6.0
     */
    ON_PLAYER_RESIZE: 'onPlayerResize',

    /**
     * Is fired when the playback of the current video has finished.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PLAYBACK_FINISHED constant.
     *
     * @event
     * @since v4.0
     */
    ON_PLAYBACK_FINISHED: 'onPlaybackFinished',

    /**
     * Is fired when an error during setup, e.g. neither HTML5/JS nor Flash can be used, or playback is encountered.
     * The passed event is of type {@link ErrorEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_ERROR constant.
     *
     * @event
     * @since v4.0
     */
    ON_ERROR: 'onError',

    /**
     * Is fired when something happens which is not as serious as an error but could potentially affect playback or other
     * functionalities.
     * The passed event is of type {@link WarningEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_WARNING constant.
     *
     * @event
     * @since v5.1
     */
    ON_WARNING: 'onWarning',

    /**
     * Is fired when the player begins to stall and to buffer due to an empty buffer.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_STALL_STARTED constant.
     *
     * In previous player versions, this was called ON_START_BUFFERING.
     *
     * @event
     * @since v7.0
     */
    ON_STALL_STARTED: 'onStallStarted',

    /**
     * Is fired when the player ends stalling due to enough data in the buffer.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_STALL_ENDED constant.
     *
     * In previous player versions, this was called ON_STOP_BUFFERING.
     *
     * @event
     * @since v7.0
     */
    ON_STALL_ENDED: 'onStallEnded',

    /**
     * Is fired when the audio track is changed.
     * The passed event is of type {@link AudioChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_CHANGED constant.
     *
     * In previous player versions, this was called ON_AUDIO_CHANGE.
     *
     * @event
     * @since v7.0
     */
    ON_AUDIO_CHANGED: 'onAudioChanged',

    /**
     * Is fired when a new audio track is added.
     * The passed event is of type {@link AudioTrackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_ADDED constant.
     *
     * @event
     * @since v7.1.4 / v7.2.0
     */
    ON_AUDIO_ADDED: 'onAudioAdded',

    /**
     * Is fired when an existing audio track is removed.
     * The passed event is of type {@link AudioTrackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_REMOVED constant.
     *
     * @event
     * @since v7.1.4 / v7.2.0
     */
    ON_AUDIO_REMOVED: 'onAudioRemoved',

    /**
     * Is fired when the subtitles/captions track is changed.
     * The passed event is of type {@link SubtitleChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SUBTITLE_CHANGED constant.
     *
     * In previous player versions, this was called ON_SUBTITLE_CHANGE.
     *
     * @event
     * @since v7.0
     */
    ON_SUBTITLE_CHANGED: 'onSubtitleChanged',

    /**
     * Is fired when changing the video quality is triggered by using setVideoQuality.
     * The passed event is of type {@link VideoQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VIDEO_QUALITY_CHANGED constant.
     *
     * @event
     * @since v7.3.1
     */
    ON_VIDEO_QUALITY_CHANGED: 'onVideoQualityChanged',

    /**
     * Is fired when changing the audio quality is triggered by using setAudioQuality.
     * The passed event is of type {@link AudioQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_QUALITY_CHANGED constant.
     *
     * @event
     * @since v7.3.1
     */
    ON_AUDIO_QUALITY_CHANGED: 'onAudioQualityChanged',

    /**
     * Is fired when changing the downloaded video quality is triggered, either by using setVideoQuality or due to
     * automatic dynamic adaptation.
     * The passed event is of type {@link VideoDownloadQualityChangeEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VIDEO_DOWNLOAD_QUALITY_CHANGE constant.
     *
     * @event
     * @since v4.0
     */
    ON_VIDEO_DOWNLOAD_QUALITY_CHANGE: 'onVideoDownloadQualityChange',

    /**
     * Is fired when changing the downloaded audio quality is triggered, either by using setAudioQuality or due to
     * automatic dynamic adaptation.
     * The passed event is of type {@link AudioDownloadQualityChangeEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_DOWNLOAD_QUALITY_CHANGE constant.
     *
     * @event
     * @since v4.0
     */
    ON_AUDIO_DOWNLOAD_QUALITY_CHANGE: 'onAudioDownloadQualityChange',

    /**
     * Is fired when the downloaded video quality has been changed successfully. It is (not necessarily directly)
     * preceded by an ON_VIDEO_DOWNLOAD_QUALITY_CHANGE event.
     * The passed event is of type {@link VideoDownloadQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VIDEO_DOWNLOAD_QUALITY_CHANGED constant.
     *
     * @event
     * @since v7.0
     */
    ON_VIDEO_DOWNLOAD_QUALITY_CHANGED: 'onVideoDownloadQualityChanged',

    /**
     * Is fired when the downloaded audio quality has been changed successfully. It is (not necessarily directly)
     * preceded by an ON_AUDIO_DOWNLOAD_QUALITY_CHANGE event.
     * The passed event is of type {@link AudioDownloadQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_DOWNLOAD_QUALITY_CHANGED constant.
     *
     * @event
     * @since v7.0
     */
    ON_AUDIO_DOWNLOAD_QUALITY_CHANGED: 'onAudioDownloadQualityChanged',

    /**
     * Is fired when the displayed video quality changed.
     * The passed event is of type {@link VideoPlaybackQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VIDEO_PLAYBACK_QUALITY_CHANGED constant.
     *
     * In previous player versions, this was called ON_VIDEO_PLAYBACK_QUALITY_CHANGE.
     *
     * @event
     * @since v7.0
     */
    ON_VIDEO_PLAYBACK_QUALITY_CHANGED: 'onVideoPlaybackQualityChanged',

    /**
     * Is fired when the played audio quality changed.
     * The passed event is of type {@link AudioPlaybackQualityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_PLAYBACK_QUALITY_CHANGED constant.
     *
     * In previous player versions, this was called ON_AUDIO_PLAYBACK_QUALITY_CHANGE.
     *
     * @event
     * @since v7.0
     */
    ON_AUDIO_PLAYBACK_QUALITY_CHANGED: 'onAudioPlaybackQualityChanged',

    /**
     * Is fired when the current playback time has changed.
     * The passed event is of type {@link PlaybackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_TIME_CHANGED constant.
     *
     * @event
     * @since v4.0
     */
    ON_TIME_CHANGED: 'onTimeChanged',

    /**
     * Is fired when a subtitle entry transitions into the active status.
     * The passed event is of type {@link SubtitleCueEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CUE_ENTER constant.
     *
     * @event
     * @since v4.0
     */
    ON_CUE_ENTER: 'onCueEnter',

    /**
     * Is fired when either the start time or the end time of a cue change.
     * The passed event is of type {@link SubtitleCueEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CUE_UPDATE constant.
     *
     * @event
     * @since v7.1
     */
    ON_CUE_UPDATE: 'onCueUpdate',

    /**
     * Is fired when an active subtitle entry transitions into the inactive status.
     * The passed event is of type {@link SubtitleCueEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CUE_EXIT constant.
     *
     * @event
     * @since v4.0
     */
    ON_CUE_EXIT: 'onCueExit',

    /**
     * Is fired when a segment is played back.
     * The passed event is of type {@link SegmentPlaybackEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SEGMENT_PLAYBACK constant.
     *
     * @event
     * @since v6.1
     */
    ON_SEGMENT_PLAYBACK: 'onSegmentPlayback',

    /**
     * Is fired when metadata (i.e. ID3 tags in HLS and EMSG in DASH) are encountered.
     * The passed event is of type {@link MetadataEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_METADATA constant.
     *
     * @event
     * @since v4.0
     */
    ON_METADATA: 'onMetadata',

    /**
     * Is fired when the controls start to fade in.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SHOW_CONTROLS constant.
     *
     * @event
     * @since v4.0
     * @deprecated deprecated and not used since 7.0, will be removed in 8.0
     * @hidden
     */
    ON_SHOW_CONTROLS: 'onShowControls',

    /**
     * Is fired when the controls start to fade out.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_HIDE_CONTROLS constant.
     *
     * @event
     * @since v4.0
     * @deprecated deprecated and not used since 7.0, will be removed in 8.0
     * @hidden
     */
    ON_HIDE_CONTROLS: 'onHideControls',

    /**
     * Is fired before a new video segment is downloaded.
     * The passed event is of type {@link VideoAdaptationEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VIDEO_ADAPTATION constant.
     *
     * <span class="highlight">[new in v6.0]</span> To overwrite the suggested quality, the new onVideoAdaptation
     * callback in the Adaptation part of the player configuration should be used. This event does not respect any
     * return values anymore.
     *
     * @event
     * @since v4.0
     */
    ON_VIDEO_ADAPTATION: 'onVideoAdaptation',

    /**
     * Is fired before a new audio segment is downloaded.
     * The passed event is of type {@link AudioAdaptationEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AUDIO_ADAPTATION constant.
     *
     * <span class="highlight">[new in v6.0]</span> To overwrite the suggested quality, the new onAudioAdaptation
     * callback in the Adaptation part of the player configuration should be used. This event does not respect any
     * return values anymore.
     *
     * @event
     * @since v4.0
     */
    ON_AUDIO_ADAPTATION: 'onAudioAdaptation',

    // never triggered?
    ON_PLAYER_CREATED: 'onPlayerCreated',

    /**
     * Is fired immediately after a download finishes successfully, or if all retries of a download failed.
     * The passed event is of type {@link DownloadFinishedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_DOWNLOAD_FINISHED constant.
     *
     * @event
     * @since v4.0
     */
    ON_DOWNLOAD_FINISHED: 'onDownloadFinished',

    /**
     * Is fired when a segment download has been finished, whether successful or not.
     * The passed event is of type {@link SegmentRequestFinishedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SEGMENT_REQUEST_FINISHED constant.
     *
     * @event
     * @since v6.0
     */
    ON_SEGMENT_REQUEST_FINISHED: 'onSegmentRequestFinished',

    /* Ad events */

    /**
     * Is fired when the ad manifest has been successfully loaded.
     * The passed event is of type {@link AdManifestLoadedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_MANIFEST_LOADED constant.
     *
     * <span class="highlight">[new in v7.0]</span> To overwrite the parsed manifest, the new onAdManifestLoaded
     * callback in the Advertising part of the player configuration should be used. This event does not respect any
     * return values anymore.
     *
     * @event
     * @since v4.0
     */
    ON_AD_MANIFEST_LOADED: 'onAdManifestLoaded',

    /**
     * Is fired when an ad manifest was successfully downloaded and parsed and the ad has been added onto the queue.
     * The passed event is of type {@link AdScheduledEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_STARTED constant.
     *
     * @event
     * @since v6.0
     */
    ON_AD_SCHEDULED: 'onAdScheduled',

    /**
     * Is fired when the playback of an ad has been started.
     * The passed event is of type {@link AdStartedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_STARTED constant.
     *
     * @event
     * @since v4.1
     */
    ON_AD_STARTED: 'onAdStarted',

    /**
     * Is fired when the playback of an ad has progressed over a quartile boundary.
     * The passed event is of type {@link AdQuartileEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_QUARTILE constant.
     *
     * @event
     * @since v7.4.6
     */
    ON_AD_QUARTILE: 'onAdQuartile',

    /**
     * Is fired when an ad has been skipped.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_SKIPPED constant.
     *
     * @event
     * @since v4.1
     */
    ON_AD_SKIPPED: 'onAdSkipped',

    /**
     * Is fired when the user clicks on the ad.
     * The passed event is of type {@link AdClickedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_STARTED constant.
     *
     * @event
     * @since v4.3
     */
    ON_AD_CLICKED: 'onAdClicked',

    /**
     * Is fired when VPAID ad changes its linearity.
     * The passed event is of type {@link AdLinearityChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_STARTED constant.
     *
     * @event
     * @since v6.0
     */
    ON_AD_LINEARITY_CHANGED: 'onAdLinearityChanged',

    /**
     * Is fired when the playback of an ad has been finished.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_PLAYBACK_FINISHED constant.
     *
     * @event
     * @since v7.0
     */
    ON_AD_PLAYBACK_FINISHED: 'onAdPlaybackFinished',

    /**
     * Is fired when the playback of an ad has been finished.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_FINISHED constant.
     *
     * @event
     * @since v4.1
     */
    ON_AD_FINISHED: 'onAdFinished',

    /**
     * Is fired when ad playback fails.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AD_STARTED constant.
     *
     * @event
     * @since v6.0
     */
    ON_AD_ERROR: 'onAdError',

    /* VR events */

    /**
     * This event is fired when the VR viewing direction changes. The minimal interval between two consecutive event
     * callbacks is specified through {@link PlayerVRAPI.setViewingDirectionChangeEventInterval}.
     * The passed event is of type {@link VRViewingDirectionChangeEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VR_VIEWING_DIRECTION_CHANGE constant.
     *
     * @event
     * @since v7.2
     */
    ON_VR_VIEWING_DIRECTION_CHANGE: 'onVRViewingDirectionChange',

    /**
     * This event is fired when the VR viewing direction did not change more than the specified threshold in the last
     * interval, after the {@link ON_VR_VIEWING_DIRECTION_CHANGE} event was triggered. The threshold can be set through
     * {@link PlayerVRAPI.setViewingDirectionChangeThreshold}.
     * The passed event is of type {@link VRViewingDirectionChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VR_VIEWING_DIRECTION_CHANGED constant.
     *
     * @event
     * @since v7.2
     */
    ON_VR_VIEWING_DIRECTION_CHANGED: 'onVRViewingDirectionChanged',

    /* Chromecast events */
    /**
     * Is fired when casting to another device, such as a ChromeCast, is available.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_AVAILABLE constant.
     *
     * @event
     * @since v4.0
     */
    ON_CAST_AVAILABLE: 'onCastAvailable',

    /**
     * Is fired when the time update from the currently used cast device is received.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_TIME_UPDATED constant.
     *
     * In previous player versions, this was called ON_CAST_TIME_UPDATE.
     *
     * @event
     * @since v7.0
     */
    ON_CAST_TIME_UPDATED: 'onCastTimeUpdated',

    /**
     * Is fired when the casting is stopped.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_STOPPED constant.
     *
     * In previous player versions, this was called ON_CAST_STOP.
     *
     * @event
     * @since v7.0
     */
    ON_CAST_STOPPED: 'onCastStopped',

    /**
     * Is fired when the casting has been initiated, but the user still needs to choose which device should be used.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_START constant.
     *
     * @event
     * @since v4.0
     */
    ON_CAST_START: 'onCastStart',

    /**
     * Is fired when playback on the cast device has started.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_PLAYING constant.
     *
     * @event
     * @since v4.0
     */
    ON_CAST_PLAYING: 'onCastPlaying',

    /**
     * Is fired when playback on the cast device has been paused.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_PAUSED constant.
     *
     * In previous player versions, this was called ON_CAST_PAUSE.
     *
     * @event
     * @since v7.0
     */
    ON_CAST_PAUSED: 'onCastPaused',

    /**
     * Is fired when playback on the cast device has finished.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_PLAYBACK_FINISHED constant.
     *
     * @event
     * @since v4.0
     */
    ON_CAST_PLAYBACK_FINISHED: 'onCastPlaybackFinished',

    /**
     * Is fired when the user has chosen a cast device and the player is waiting for the device to get ready for
     * playback.
     * The passed event is of type {@link CastWaitingForDeviceEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_CAST_WAITING_FOR_DEVICE constant.
     *
     * @event
     * @since v4.0
     */
    ON_CAST_WAITING_FOR_DEVICE: 'onCastWaitingForDevice',

    /**
     * Is fired when the Cast app is either launched successfully or an active Cast session is resumed successfully.
     * The passed event is of type {@link CastStartedEvent}.
     *
     * Also accessible via the
     * bitmovin.player.EVENT.ON_CAST_STARTED constant.
     *
     * In versions previous to v7.0 this event was called ON_CAST_LAUNCHED.
     *
     * @event
     * @since v7.0
     */
    ON_CAST_STARTED: 'onCastStarted',

    /* player exclusive events */

    /**
     * Is fired when a new source is loaded. This does not mean that loading of the new manifest has been finished.
     * The passed event is of type {@link SourceLoadedEvent}.
     *
     * Also accessible via the
     * bitmovin.player.EVENT.ON_SOURCE_LOADED constant.
     *
     * @event
     * @since v4.2
     */
    ON_SOURCE_LOADED: 'onSourceLoaded',

    /**
     * Is fired when the current source has been unloaded.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the
     * bitmovin.player.EVENT.ON_SOURCE_LOADED constant.
     *
     * @event
     * @since v4.2
     */
    ON_SOURCE_UNLOADED: 'onSourceUnloaded',

    /**
     * Is fired when a period switch starts.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PERIOD_SWITCH constant.
     *
     * @event
     * @since v6.2
     */
    ON_PERIOD_SWITCH: 'onPeriodSwitch',

    /**
     * Is fired when a period switch was performed.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PERIOD_SWITCHED constant.
     *
     * @event
     * @since v4.0
     */
    ON_PERIOD_SWITCHED: 'onPeriodSwitched',

    /**
     * Is fired if the player is paused or in buffering state and the timeShift offset has exceeded the available
     * timeShift window.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_DVR_WINDOW_EXCEEDED constant.
     *
     * @event
     * @since v4.0
     */
    ON_DVR_WINDOW_EXCEEDED: 'onDVRWindowExceeded',

    /**
     * Is fired when a new subtitles/captions track is added, for example using the addSubtitle API call or when
     * in-stream closed captions are encountered.
     * The passed event is of type {@link SubtitleAddedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SUBTITLE_ADDED constant.
     *
     * @event
     * @since v4.0
     */
    ON_SUBTITLE_ADDED: 'onSubtitleAdded',

    /**
     * Is fired when an external subtitle file has been removed so it is possible to update the controls accordingly.
     * The passed event is of type {@link SubtitleRemovedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SUBTITLE_REMOVED constant.
     *
     * @event
     * @since v4.0
     */
    ON_SUBTITLE_REMOVED: 'onSubtitleRemoved',

    /**
     * Is fired when the stereo mode during playback of VR content changes.
     * The passed event is of type {@link VRStereoChangedEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_VR_STEREO_CHANGED constant.
     *
     * @event
     * @since v6.0
     */
    ON_VR_STEREO_CHANGED: 'onVRStereoChanged',

    /**
     * Is fired when player enters macOS picture in picture mode.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PICTURE_IN_PICTURE_ENTER constant.
     *
     * @event
     * @since v7.1
     */
    ON_PICTURE_IN_PICTURE_ENTER: 'onPictureInPictureEnter',

    /**
     * Is fired when player exits macOS picture in picture mode.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_PICTURE_IN_PICTURE_EXIT constant.
     *
     * @event
     * @since v7.1
     */
    ON_PICTURE_IN_PICTURE_EXIT: 'onPictureInPictureExit',

    /**
     * Is fired when the airplay playback target picker is shown.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_SHOW_AIRPLAY_TARGET_PICKER constant.
     *
     * @event
     * @since v7.1
     */
    ON_SHOW_AIRPLAY_TARGET_PICKER: 'onShowAirplayTargetPicker',

    /**
     * Is fired when the airplay playback target turned available.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_AIRPLAY_AVAILABLE constant.
     *
     * @event
     * @since v7.1
     */
    ON_AIRPLAY_AVAILABLE: 'onAirplayAvailable',

    /**
     * Is fired when the player instance is destroyed.
     * The passed event is of type {@link PlayerEvent}.
     *
     * Also accessible via the bitmovin.player.EVENT.ON_DESTROY constant.
     *
     * @event
     * @since v7.2
     */
    ON_DESTROY: 'onDestroy'
};