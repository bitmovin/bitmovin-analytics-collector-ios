import BitmovinPlayer
import CoreCollector

extension Player {
    /**
     Returns the current playback time in seconds.
     For VoD streams the returned time ranges between 0 and the duration of the asset.
     For live streams a Unix timestamp denoting the current playback position is returned.

     Used by Bitmovin Analytics
     */
    var currentTimeMillis: CMTime? {
        Util.timeIntervalToCMTime(self.currentTime)
    }

    /**
    Returns the total duration in seconds of the current video or INFINITY if it’s a live stream.

    Used by Bitmovin Analytics
     */
    var durationMillis: CMTime? {
        Util.timeIntervalToCMTime(self.duration)
    }
}
