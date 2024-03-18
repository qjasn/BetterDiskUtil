//
//  DiskLists.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/16.
//

import SwiftUI

struct DiskLists: View {
    @Binding var main_disk:Dictionary<String,Array<Dictionary<String,String>>>
    var body: some View {
        List{
            let internal_d = $main_disk["in"]
            Section{
                ForEach(internal_d, id: \.self) { item in
                    DiskItems(name: item["name"])
                }
                
            } header: {
                Text("Internal")
            }
            Section{
                ForEach($main_disk["extra"], id: \.self) { item in
                    Text(item["name"])

                }
            } header: {
                Text("External")
            }
            Section{
                ForEach($main_disk["disk"], id: \.self) { item in
                    Text(item["name"])

                }
            } header: {
                Text("External")
            }
        }
        .frame(minWidth:150,idealWidth: 200)
        .listStyle(SidebarListStyle())
        .background(Color.clear)
    }
}
