//
//  notification.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/23.
//

import Foundation

class DiskUtilNotification{
    public static let didDiskLoadFinished = Notification.Name(rawValue: "better_diskutil.diskload.didDiskLoadFinished")
    public static let theDiskShouldRefresh = Notification.Name(rawValue: "better_diskutil.diskload.theDiskShouldRefresh")

}
