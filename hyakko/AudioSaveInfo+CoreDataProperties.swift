//
//  AudioSaveInfo+CoreDataProperties.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import Foundation
import CoreData


extension AudioSaveInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioSaveInfo> {
        return NSFetchRequest<AudioSaveInfo>(entityName: "AudioSaveInfo")
    }

    @NSManaged public var filePath: String?
    @NSManaged public var saveDate: NSDate?
    @NSManaged public var displayName: String?

}
