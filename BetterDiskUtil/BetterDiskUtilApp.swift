//
//  BetterDiskUtilApp.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/10.
//

import SwiftUI

@main
struct BetterDiskUtilApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }.commands {
            SidebarCommands()
        }
    }
}
