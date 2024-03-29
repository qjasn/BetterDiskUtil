//
//  MainView.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/15.
//

import SwiftUI

struct MainView: View {
    @State var refreshing = false
    var body: some View {
        NavigationView{
            DiskLists()
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggle_toolbar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
            ToolbarItem(placement: .navigation, content: {
                Button(action: refesh, label: {
                    Image(systemName: "arrow.clockwise")
                }).disabled(refreshing)
            })
        }
    }
    func refesh(){
        refreshing = true
        NotificationCenter.default.post(name: DiskUtilNotification.theDiskShouldRefresh, object: true)
        NotificationCenter.default.addObserver(forName: DiskUtilNotification.didDiskLoadFinished, object: nil, queue: OperationQueue.main){ (note) in
            refreshing = false
        }
    }
    
}
func toggle_toolbar(){
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
class TriggerViewModel: ObservableObject {
    func updateView() {
        self.objectWillChange.send()
    }
}
#Preview {
    MainView()
}
