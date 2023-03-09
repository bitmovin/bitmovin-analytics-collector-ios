public enum CodecUtils {
    static func getSupportedVideoCodecs() -> [String] {
        ["avc", "hevc"]
    }

    // ac-3 -> Dolby Digital
    // ec-3 -> Dolby Digital plus
    // vorbis, opus -> open source codecs
    static let AUDIO_CODECS = ["mp4a", "ec-3", "ac-3", "opus", "vorbis"]
    static let VIDEO_CODECS = ["avc", "hvc1", "av01", "av1", "hev1", "vp9", "hevc", "mpeg4"]

    public static func isVideoCodec(_ codec: String) -> Bool {
        !codec.isEmpty && VIDEO_CODECS.contains { codec.starts(with: $0) }
    }

    public static func isAudioCodec(_ codec: String) -> Bool {
        !codec.isEmpty && AUDIO_CODECS.contains { codec.starts(with: $0) }
    }
}
