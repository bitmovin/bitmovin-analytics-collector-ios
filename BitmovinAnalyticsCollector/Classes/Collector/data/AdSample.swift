import Foundation

public class AdSample {
    var adStartupTime: Int64?
    var clicked: Int = 0
    var clickPosition: Int64?
    var closed: Int = 0
    var closePosition: Int64?
    var completed: Int = 0
    var midpoint: Int?
    var percentageInViewport: Int?
    var quartile1: Int = 0
    var quartile3: Int = 0
    var skipped: Int = 0
    var skipPosition: Int64?
    var started: Int = 0
    var timeHovered: Int64?
    var timeInViewport: Int64?
    var timePlayed: Int64?
    var timeUntilHover: Int64?
    var adPodPosition: Int?
    var exitPosition: Int64?
    var playPercentage: Int?
    var skipPercentage: Int?
    var clickPercentage: Int?
    var closePercentage: Int?
    var errorPosition: Int64?
    var errorPercentage: Int?
    var timeToContent: Int64?
    var timeFromContent: Int64?
    var manifestDownloadTime: Int64?
    var errorCode: Int?
    var errorData: String?
    var errorMessage: String?
    var ad: AnalyticsAd = AnalyticsAd()
}
