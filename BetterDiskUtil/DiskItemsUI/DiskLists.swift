//
//  DiskLists.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/16.
//

import SwiftUI

struct DiskLists: View {
    @StateObject var DisksContorl = Disk()
    @State var has_updated = false
    var disk_active = DiskActive()
    var body: some View {
        ZStack{
            if has_updated{
                List{
                    Section{
                        ForEach(DisksContorl.main_disk["in"]!, id: \.self) { item in
                            DiskItems(name: item["name"]!, id: item["id"]!, index: DisksContorl.build_index[item["id"]!] as! Dictionary<String, Any>)
                        }
                        
                    } header: {
                        Text("Internal")
                    }
                    Section{
                        ForEach(DisksContorl.main_disk["extra"]!, id: \.self) { item in
                            DiskItems(name: item["name"]!,  id: item["id"]!, index: DisksContorl.build_index[item["id"]!] as! Dictionary<String, Any>)
                        }
                    } header: {
                        Text("External")
                    }
                    Section{
                        ForEach(DisksContorl.main_disk["disk"]!, id: \.self) { item in
                            DiskItems(name: item["name"]!,  id: item["id"]!, index: DisksContorl.build_index[item["id"]!] as! Dictionary<String, Any>)
                        }
                    } header: {
                        Text("Disk Image")
                    }
                }
                .frame(minWidth:150,idealWidth: 170)
                .listStyle(SidebarListStyle())
                .background(Color.clear)
            } else {
                ProgressView()
            }
        }.onAppear {
            Task(priority: .background){
                await DisksContorl.update()
                disk_active.run()
            }
            NotificationCenter.default.addObserver(forName: DiskUtilNotification.didDiskLoadFinished, object: nil, queue: OperationQueue.main){ (note) in
                if note.object! as! Bool{
                    DisksContorl.update_sync()
                }
                has_updated = note.object! as! Bool
                disk_active.has_updated = note.object! as! Bool
            }
            NotificationCenter.default.addObserver(forName: DiskUtilNotification.theDiskShouldRefresh, object: nil, queue: OperationQueue.main){ (note) in
                Task(priority: .background) {
                    has_updated = false
                    await DisksContorl.update()
                }
            }
        }
    }
}
