//
//  MainView.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/15.
//

import SwiftUI

struct MainView: View {
    @StateObject var DisksContorl = Disk()
    var body: some View {
        NavigationView{
            DiskLists(main_disk: $DisksContorl.main_disk)
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggle_toolbar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
            ToolbarItem(placement: .navigation, content: {
                Button(action: refesh, label: {
                    Image(systemName: "arrowshape.up.circle")
                })
            })
        }
    }
    func refesh(){
        DisksContorl.update()
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
