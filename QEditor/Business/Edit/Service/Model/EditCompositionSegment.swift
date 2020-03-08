//
//  EditCompositionSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

struct AVAssetKey {
    static let tracks = "tracks"
    static let duration = "duration"
    static let metadata = "commonMetadata"
}

public protocol EditCompositionSegment {
    
    /// segment的唯一标识符
    var id: Int { get }
    
    /// segment的时长
    var duration: Double { get }
    
    /// segment在composition中的range
    var rangeAtComposition: CMTimeRange { get }
    
}

func == (lhs: EditCompositionSegment, rhs: EditCompositionSegment) -> Bool {
    return lhs.id == rhs.id
}
