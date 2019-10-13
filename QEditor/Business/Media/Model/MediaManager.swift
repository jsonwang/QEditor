//
//  MediaManager.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import Photos
import UIKit

protocol MediaManagerDelegate: class {
    
    func didFetchAllVideos(videos: [MediaVideoModel])
    
    func didFetchAllPhotos(photos: [MediaImageModel])
    
}

class MediaManager {
    
    public weak var delegate: MediaManagerDelegate?
    
    private var videoArray: [MediaVideoModel] = []
    
    private var imageArray: [MediaImageModel] = []
    
    public func fetchAllPhotos() {
        DispatchQueue.global().async {
            self.imageArray = []
            let option = PHFetchOptions()
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: option)
            fetchResult.enumerateObjects { (asset, _, _) in
                let m = MediaImageModel()
                m.asset = asset
                self.imageArray.append(m)
            }
            DispatchQueue.main.async {
                self.delegate?.didFetchAllPhotos(photos: self.imageArray)
            }
        }
    }
    
    public func fetchAllVideos() {
        DispatchQueue.global().async {
            self.videoArray = []
            let option = PHFetchOptions()
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .video, options: option)
            fetchResult.enumerateObjects { (asset, _, _) in
                let m = MediaVideoModel()
                m.asset = asset
                let option = PHVideoRequestOptions()
                option.version = .current
                option.deliveryMode = .automatic
                option.isNetworkAccessAllowed = true
                let sema = DispatchSemaphore(value: 0)
                PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: option) { (avasset, mix, info) in
                    guard info != nil && avasset != nil && avasset!.isKind(of: AVURLAsset.self) else {
                        sema.signal()
                        return
                    }
                    m.videoTime = avasset!.duration
                    m.url = (avasset as! AVURLAsset).url
                    let second = Int(ceil(Double(m.videoTime.value / Int64(m.videoTime.timescale))))
                    if second >= 3600 {
                        m.formatTime = "\(second % 3600)" + ":" + String(format: "%.2d", second / 60) + ":" + String(format: "%.2d", second % 60)
                    } else if second >= 60 {
                        m.formatTime = "\(second / 60)" + ":" + String(format: "%.2d", second % 60)
                    } else {
                        m.formatTime = "00" + ":" + String(format: "%.2d", second % 60)
                    }
                    sema.signal()
                }
                sema.wait()
                self.videoArray.append(m)
            }
            DispatchQueue.main.sync {
                self.delegate?.didFetchAllVideos(videos: self.videoArray)
            }
        }
    }
    
    public func fetchPhoto(in asset: PHAsset, _ closure: @escaping (_ image: UIImage?) -> Void) {
        //获得相对清晰的MEDIA_ITEM_SIZE尺寸的缩略图
        let scale = UIScreen.main.scale
        let size = CGSize.init(width: MEDIA_ITEM_SIZE * scale, height: MEDIA_ITEM_SIZE * scale)
        let length = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: length, height: length)
        let cropRect = square.applying(.init(scaleX: CGFloat(1 / asset.pixelWidth), y: CGFloat(1 / asset.pixelHeight)))
        autoreleasepool {
            let opt = PHImageRequestOptions()
            opt.deliveryMode = .highQualityFormat
            opt.isSynchronous = false
            opt.resizeMode = .exact
            opt.normalizedCropRect = cropRect
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: opt) { (image, info) in
                closure(image)
            }
        }
    }
    
}
