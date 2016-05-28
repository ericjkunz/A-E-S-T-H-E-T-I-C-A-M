//
//  ImageDownloader.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RealmSwift
import RandomKit

final class ImageDownloader {
    
    // MARK: Singleton
    
    static let sharedInstance = ImageDownloader()
    
    // MARK: Private Properties
    
    private static let saveQueue = dispatch_queue_create("com.nicholasleedesigns.aestheticam.save", DISPATCH_QUEUE_SERIAL)
    private let accountKey = ""
    
    // MARK: Initialiaztion
    
    private init() {}
    
    // MARK: Auth
    
    private func authorizationHeaderValue() -> String {
        var result = ""
        let loginString = accountKey + ":" + accountKey
        if let loginData = loginString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let encodedLoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            result = "Basic " + encodedLoginString
        }
        return result
    }
    
    // MARK: Download
    
    func download() {
        
        let realm = try! Realm()
        
        if realm.objects(Image).count >= 25 {
            return
        }
        
        let url = "https://api.datamarket.azure.com/Bing/Search/v1/Image"
        let params = [
            "Query": Bool.random() ? "'aesthetic transparent png'" : "'vaporwave transparent png'",
            "Adult": "'Strict'",
            "ImageFilters": "'Color:Color'",
            "$format": "JSON"
        ]
        request(.GET, url, parameters: params, encoding: .URLEncodedInURL, headers: ["Authorization" : authorizationHeaderValue()]).responseJSON { result in
            guard let v = result.result.value as? [String: AnyObject], data = v["d"] as? [String: AnyObject], results = data["results"] as? [[String : AnyObject]] else {
                return
            }
            let urls = results.flatMap({ $0["MediaUrl"] as? String }).flatMap({ NSURL(string: $0) })
            self.getImages(urls)
        }
    }
    
    private func getImages(urls: [NSURL]) {
        let requests = urls.map({ request(.GET, $0) })
        requests.forEach {
            $0.responseImage { result in
                guard let image = result.result.value else {
                    return
                }
                dispatch_async(ImageDownloader.saveQueue) {
                    let realm = try! Realm()
                    guard let data = UIImagePNGRepresentation(image) else {
                        return
                    }
                    do {
                        
                        let urlString = result.request!.URLString
                        
                        let pred = NSPredicate(format: "%K = %@", argumentArray: ["url", urlString])
                        
                        guard realm.objects(Image).filter(pred).first == nil else {
                            return
                        }
                        
                        try realm.write {
                            let img = Image()
                            img.data = data
                            img.url = result.request!.URLString
                            realm.add(img)
                        }
                    }
                    catch {}
                }
            }
        }
    }
    
    // MARK: Random
    
    func getRandomImage() -> UIImage? {

        guard let realm = try? Realm(), entry = realm.objects(Image).random else {
            return nil
        }
        return UIImage(data: entry.data)
    }
    
}