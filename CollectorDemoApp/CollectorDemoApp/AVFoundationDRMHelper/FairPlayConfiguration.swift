import Foundation

class FairPlayConfiguration {
    let certificateUrl: URL
    var licenseUrl: URL?

    var licenseRequestHeaders: Dictionary<String, String>?
    var certificateRequestHeaders: Dictionary<String, String>?

    var prepareMessage : ((Data, String) -> Data)?
    var prepareContentId : ((String) -> String)?
    var prepareCertificate : ((Data) -> Data)?
    var prepareLicense : ((Data) -> Data)?

    init(licenseUrl: URL, certificateUrl: URL) {
        self.licenseUrl = licenseUrl
        self.certificateUrl = certificateUrl
    }

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }
}
