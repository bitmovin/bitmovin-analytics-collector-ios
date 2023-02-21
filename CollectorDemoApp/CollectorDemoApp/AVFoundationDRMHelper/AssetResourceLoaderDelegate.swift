/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `AssetResourceLoaderDelegate` is a class that implements the `AVAssetResourceLoaderDelegate` protocol to respond
 to content key requests using FairPlay Streaming.
 */

import AVFoundation

class AssetResourceLoaderDelegate: NSObject {
    weak var asset: Asset?

    init(asset: Asset) {
        self.asset = asset
    }

    // MARK: Types

    enum ProgramError: Error {
        case missingApplicationCertificate
        case noCKCReturnedByKSM
    }

    // MARK: Properties

    /// A dictionary mapping content key identifiers to their associated stream name.
    var contentKeyToStreamNameMap = [String: String]()

    /// The DispatchQueue to use for AVAssetResourceLoaderDelegate callbacks.
    fileprivate let resourceLoadingRequestQueue = DispatchQueue(label: "com.example.apple-samplecode.resourcerequests")

    // MARK: API

    func requestApplicationCertificate(completion: @escaping (Data?, Error?) -> Void) {
        guard let fairPlayConfig = self.asset?.fairPlayConfig else {
            return
        }

        let urlRequest = NSMutableURLRequest(url: fairPlayConfig.certificateUrl)

        // set request headers
        setCertificateRequestHeaders(fairPlayConfig: fairPlayConfig, certificateRequest: urlRequest)

        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {data, _, _ in
            if data == nil {
                completion(nil, NSError(domain: "com.apple.sample", code: 1_000, userInfo: nil))
                return
            }

            if fairPlayConfig.prepareCertificate != nil {
                let data = fairPlayConfig.prepareCertificate!(data!)
                completion(data, nil)
                return
            }

            completion(data, nil)
        }

        task.resume()
    }

    func requestContentKeyFromKeySecurityModule(spcData: Data, assetIdString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let fairPlayConfig = self.asset?.fairPlayConfig else {
            completion(nil, NSError(domain: "com.apple.sample", code: 1_000, userInfo: nil))
            return
        }

        let urlRequest = NSMutableURLRequest(url: fairPlayConfig.licenseUrl!)
        urlRequest.httpMethod = "POST"

        if fairPlayConfig.prepareMessage != nil {
            urlRequest.httpBody = fairPlayConfig.prepareMessage!(spcData, assetIdString)
        } else {
            let base64Spc = String(data: spcData.base64EncodedData(), encoding: .utf8)!
            let urlEncodedSpc = base64Spc.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            let postDataString = String(format: "spc=%@&assetId=%@", urlEncodedSpc, assetIdString)
            urlRequest.httpBody = postDataString.data(using: .utf8)
        }

        // set http headers
        setLicenseRequestHeaders(fairPlayConfig: fairPlayConfig, urlRequest: urlRequest)

        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {data, _, _ in
            if data == nil {
                completion(nil, NSError(domain: "com.apple.sample", code: 1_000, userInfo: nil))
                return
            }

            var ckcDataResult: Data?
            if fairPlayConfig.prepareLicense != nil {
                ckcDataResult = fairPlayConfig.prepareLicense!(data!)
            } else {
                var ckcString = String(data: data!, encoding: .utf8)!
                if ckcString.prefix(5) == "<ckc>" {
                    let start = ckcString.index(ckcString.startIndex, offsetBy: 5)
                    let end = ckcString.index(ckcString.index(before: ckcString.endIndex), offsetBy: -5)
                    let range = start..<end
                    ckcString = String(ckcString[range])
                }
                ckcDataResult = Data(base64Encoded: ckcString)
            }

            completion(ckcDataResult, nil)
        }

        task.resume()
    }

    func shouldLoadOrRenewRequestedResource(resourceLoadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = resourceLoadingRequest.request.url else {
            return false
        }

        // AssetLoaderDelegate only should handle FPS Content Key requests.
        if url.scheme != "skd" {
            return false
        }

        resourceLoadingRequestQueue.async { [weak self] in
            self?.prepareAndSendContentKeyRequest(resourceLoadingRequest: resourceLoadingRequest)
        }

        return true
    }

    func prepareAndSendContentKeyRequest(resourceLoadingRequest: AVAssetResourceLoadingRequest) {
        guard let contentKeyIdentifierURL = resourceLoadingRequest.request.url,
            let assetIDString = self.asset?.fairPlayConfig?.prepareContentId?(contentKeyIdentifierURL.absoluteString),
            let assetIDData = assetIDString.data(using: .utf8) else {
                print("Failed to get url or assetIDString for the request object of the resource.")
                return
        }

        let provideOnlineKey: () -> Void = { () in
            self.requestApplicationCertificate { data, error in
                do {
                    let spcData = try resourceLoadingRequest.streamingContentKeyRequestData(forApp: data!,
                                                                                             contentIdentifier: assetIDData,
                                                                                             options: nil)

                    // Send SPC to Key Server and obtain CKC.
                    self.requestContentKeyFromKeySecurityModule(spcData: spcData, assetIdString: assetIDString) { ckcData, error in
                        guard error == nil, let ckcDat = ckcData else {
                            resourceLoadingRequest.finishLoading(with: error)
                            return
                        }

                        resourceLoadingRequest.dataRequest?.respond(with: ckcDat)
                        /*
                         You should always set the contentType before calling finishLoading() to make sure you
                         have a contentType that matches the key response.
                         */
                        resourceLoadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryContentKeyType
                        resourceLoadingRequest.finishLoading()
                    }
                } catch {
                    resourceLoadingRequest.finishLoading(with: error)
                }
            }
        }

        #if os(iOS)
        /*
         Look up if this request should request a persistable content key or if there is an existing one to use on disk.
         */

        /*
        Make sure this key request supports persistent content keys before proceeding.
         
        Clients can respond with a persistent key if allowedContentTypes is nil or if allowedContentTypes
        contains AVStreamingKeyDeliveryPersistentContentKeyType. In all other cases, the client should
        respond with an online key.
        */
        if  let contentTypes = resourceLoadingRequest.contentInformationRequest?.allowedContentTypes,
            !contentTypes.contains(AVStreamingKeyDeliveryPersistentContentKeyType) {
            // Fallback to provide online FairPlay Streaming key from key server.
            provideOnlineKey()

            return
        }
        #endif

        // Provide online FairPlay Streaming key from key server.
        provideOnlineKey()
    }
}

// MARK: - AVAssetResourceLoaderDelegate protocol methods extension
extension AssetResourceLoaderDelegate: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("\(#function) was called in AssetLoaderDelegate with loadingRequest: \(loadingRequest)")

        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: loadingRequest)
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        print("\(#function) was called in AssetLoaderDelegate with renewalRequest: \(renewalRequest)")

        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: renewalRequest)
    }
}

// MARK: - Private

func setLicenseRequestHeaders(fairPlayConfig: FairPlayConfiguration, urlRequest: NSMutableURLRequest) {
    guard let headers = fairPlayConfig.licenseRequestHeaders else {
        return
    }

    // set default values
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")

    // set values defined in drm configuration which can overwrite the default values
    for (key, value) in headers {
        urlRequest.setValue(value, forHTTPHeaderField: key)
    }
}

func setCertificateRequestHeaders(fairPlayConfig: FairPlayConfiguration, certificateRequest: NSMutableURLRequest) {
    guard let headers = fairPlayConfig.certificateRequestHeaders else {
        return
    }

    for (key, value) in headers {
        certificateRequest.setValue(value, forHTTPHeaderField: key)
    }
}
