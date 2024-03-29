//
//  DiskItems.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/15.
//

import SwiftUI

struct DiskItems: View {
    @State var name:String
    @State var id:String
    @State var index:Dictionary<String,Any>
    var body: some View {
        DisclosureGroup{
            ForEach(index.keys.sorted(), id:\.self){disk_i in
                if let part = (index[disk_i] as! Dictionary<String,Any>)["part"]{
                    let part = part as! Array<Dictionary<String,String>>
                    DisclosureGroup{
                        ForEach(part,id: \.self){item in
                            DiskSubItems(name: item["name"]!, id: item["id"]!)
                        }
                    } label: {
                        DiskSubItems(name: (index[disk_i] as! Dictionary<String,Any>)["name"] as! String, id: disk_i)
                    }
                } else {
                    DiskSubItems(name: (index[disk_i] as! Dictionary<String,Any>)["name"] as! String, id: disk_i)
                }
            }
        } label: {
            DiskSubItems(name: name, id: id)
        }
    }
}

struct DiskSubItems: View {
    @State var name:String
    @State var id:String
    var body: some View {
        NavigationLink(destination: DiskDetail(id: id)){
            HStack{
                Image(systemName: "internaldrive")
                Text(name)
            }
        }
    }
}
