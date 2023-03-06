class VideoAssets {
    static let sintel: String = "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    static let redbull: String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    static let liveSim: String = "https://bitcdn-kronehit.bitmovin.com/v2/hls/playlist.m3u8"

    // MARK: - Casting receiver-v3 compatible sources
    static let sintelCasting: String = "https://bitmovin-a.akamaihd.net/content/sintel/Sintel.mp4"
    static let redbullCasting: String = "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4"

    // MARK: - Failing Streams
    static let corruptRedBull: String = "http://bitdash-a.akamaihd.net/content/analytics-teststreams/redbull-parkour/corrupted_first_segment.mpd"
    static let wrongUrlSource = "https://test123.com/master.m3u8"

    // MARK: - IVS Streams
    // 1080p30
    static let ivsLive1080p = "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.DmumNckWFTqz.m3u8"
    // Square Video
    static let ivsLiveSquare = "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.XFAcAcypUxQm.m3u8"
    static let ivsVOD = "https://d6hwdeiig07o4.cloudfront.net/ivs/956482054022/cTo5UpKS07do/2020-07-13T22-54-42.188Z/OgRXMLtq8M11/media/hls/master.m3u8"
}
