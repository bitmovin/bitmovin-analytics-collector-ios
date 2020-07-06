import Foundation

public class DrmPerformanceInfo {
    var drmType: String
    var drmLoadTime: Int64? // in milliseconds
    
    init(drmType: String) {
        self.drmType = drmType
    }

    init(drmType: String, drmLoadTime: Int64?) {
        self.drmType = drmType
        self.drmLoadTime = drmLoadTime
    }
}
