//
//  DiskDetail.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/15.
//

import SwiftUI

struct DiskDetail: View {
    var id:String
    var detail:Dictionary<String,Any>
    init(id: String) {
        self.id = id
        self.detail = get_disk_detail(id: id)
    }
    var body: some View {
        if detail["error"] == nil{
            ZStack{
                HStack{
                    Text("DeviceIdentifier:")
                    Text(detail["DeviceIdentifier"] as! String)
                }
            }
        }else{
            ZStack{
                Text("Error")
            }
        }
    }
}

#Preview {
    DiskDetail(id: "disk0")
}
