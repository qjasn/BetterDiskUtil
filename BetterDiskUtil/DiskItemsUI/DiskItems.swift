//
//  DiskItems.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/15.
//

import SwiftUI

struct DiskItems: View {
    @Binding var name:String
    var body: some View {
        HStack{
            Image(systemName: "internaldrive")
            Text(name)
        }
    }
}
