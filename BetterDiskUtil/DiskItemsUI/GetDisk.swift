//
//  GetDisk.swift
//  BetterDiskUtil
//
//  Created by qjasn on 2024/3/16.
//

import Foundation

func get_all_disks() -> Dictionary<String,Any>{
    let diskutil = Process()
    diskutil.launchPath = "/usr/sbin/diskutil"
    diskutil.arguments = ["list","-plist"]
    let pipe = Pipe()
    diskutil.standardOutput = pipe
    try! diskutil.run()
    diskutil.waitUntilExit()
    let disks_text = (try! pipe.fileHandleForReading.readToEnd())!
    let data = (try? PropertyListSerialization.propertyList(from: disks_text, format: nil) as? Dictionary<String,Any>)!
    return data
}

func get_disk_detail(id:String) -> Dictionary<String,Any>{
    let diskutil = Process()
    diskutil.launchPath="/usr/sbin/diskutil"
    diskutil.arguments = ["info","-plist",id]
    let detail_pipe = Pipe()
    diskutil.standardOutput = detail_pipe
    try! diskutil.run()
    diskutil.waitUntilExit()
    let disks_text = (try! detail_pipe.fileHandleForReading.readToEnd())!
    let data = (try? PropertyListSerialization.propertyList(from: disks_text, format: nil) as? Dictionary<String,Any>)!
    return data
}
class DiskActive{
    let diskutil = Process()
    let pipe = Pipe()
    var has_updated = false
    init(){
        diskutil.launchPath="/usr/sbin/diskutil"
        diskutil.arguments = ["activity"]
        diskutil.standardOutput = pipe
        diskutil.standardError = pipe
    }
    func run(){
        Task(priority: .background){
            var before_pipe = pipe.fileHandleForReading.availableData
            while true{
                let after_pipe = pipe.fileHandleForReading.availableData
                if after_pipe != before_pipe && self.has_updated{
                    before_pipe = after_pipe
                    NotificationCenter.default.post(name: DiskUtilNotification.theDiskShouldRefresh, object: true)
                    self.has_updated = false
                }
                try! await Task.sleep(nanoseconds: 500000000)
            }
        }
        try! diskutil.run()
    }
}
class Disk: ObservableObject{
    // Provided for view updates
    @Published var all_disks =  get_all_disks()
    @Published var whole_disks:Array<String>=[]
    @Published var all_disks_and_partitions:Array<Dictionary<String,Any>>=[]
    @Published var main_disk=[
        "in":Array<Dictionary<String,String>>(),
        "extra":Array<Dictionary<String,String>>(),
        "disk":Array<Dictionary<String,String>>()
    ]
    @Published var build_index:Dictionary<String,Any>=[:]
    // Internal update usage
    var tmp_all_disks =  get_all_disks()
    var tmp_whole_disks:Array<String> = []
    var tmp_all_disks_and_partitions:Array<Dictionary<String,Any>> = []
    var tmp_main_disk=[
        "in":Array<Dictionary<String,String>>(),
        "extra":Array<Dictionary<String,String>>(),
        "disk":Array<Dictionary<String,String>>()
    ]
    var tmp_build_index:Dictionary<String,Any>=[:]
    
    var data_update_pipe:Pipe = Pipe()
    
    // Update internal var
    func update() async{
        tmp_main_disk=[
            "in":Array<Dictionary<String,String>>(),
            "extra":Array<Dictionary<String,String>>(),
            "disk":Array<Dictionary<String,String>>()
        ]
        tmp_build_index=[:]
        self.tmp_all_disks = get_all_disks()
        self.tmp_whole_disks = self.tmp_all_disks["WholeDisks"] as! Array<String>
        self.tmp_all_disks_and_partitions = self.all_disks["AllDisksAndPartitions"] as! Array<Dictionary<String,Any>>
        self.build_main_disk()
        self.build_disks_index()
        NotificationCenter.default.post(name: DiskUtilNotification.didDiskLoadFinished, object: true)
        
    }
    // sync internal var to public var
    func update_sync(){
        self.all_disks = tmp_all_disks
        self.whole_disks = tmp_whole_disks
        self.all_disks_and_partitions = tmp_all_disks_and_partitions
        self.main_disk = tmp_main_disk
        self.build_index = tmp_build_index
    }
    func build_disks_index(){
        for i in tmp_main_disk["in"]! + tmp_main_disk["extra"]! + tmp_main_disk["disk"]!{
            self.tmp_build_index.updateValue(simplify(_id: i["id"]!), forKey: i["id"]!)
        }
    }
    func build_main_disk(){
        for i in self.tmp_whole_disks{
            let detail = get_disk_detail(id: i)
            if detail["Internal"] != nil && detail["BusProtocol"] != nil{
                if detail["APFSPhysicalStores"] == nil && detail["Internal"] as! Bool{
                    let tmp = [
                        "id":i,
                        "name":detail["MediaName"] as! String
                    ]
                    tmp_main_disk["in"]!.append(tmp)
                } else if detail["APFSPhysicalStores"] == nil && detail["BusProtocol"] as! String == "USB"{
                    let tmp = [
                        "type":"extra",
                        "id":i,
                        "name":detail["MediaName"] as! String
                    ]
                    tmp_main_disk["extra"]!.append(tmp)
                } else if detail["APFSPhysicalStores"] == nil && detail["BusProtocol"] as! String == "Disk Image"{
                    let tmp = [
                        "type":"disk",
                        "id":i,
                        "name":detail["MediaName"] as! String
                    ]
                    tmp_main_disk["disk"]!.append(tmp)
                }
            }
        }
    }
    func simplify(_id:String) -> Dictionary<String,Any>{
        var dict:Dictionary<String,Any> = [:]
        for i in self.all_disks_and_partitions{
            if i["DeviceIdentifier"] as! String == _id {
                if i["Partitions"] != nil {
                    for l in i["Partitions"] as! Array<Dictionary<String,Any>>{
                        var sub_items = simplify_sub(_id: l["DeviceIdentifier"] as! String)
                        var tmp_name = ""
                        if let name = sub_items["map"] {
                            tmp_name = "Containar " + (name as! String)
                        } else {
                            tmp_name = "Containar " + (l["DeviceIdentifier"] as! String)
                        }
                        if l["VolumeName"] != nil {
                            tmp_name = l["VolumeName"] as! String
                        }
                        sub_items.updateValue(tmp_name, forKey: "name")
                        dict.updateValue(sub_items, forKey: l["DeviceIdentifier"] as! String)
                    }
                }
            }
        }
        return dict
    }
    func simplify_sub(_id:String) -> Dictionary<String,Any>{
        var dict = [String:Any]()
        for i in self.all_disks_and_partitions{
            if let physical_stores = i["APFSPhysicalStores"] {
                let tmp = physical_stores as! Array<Dictionary<String,Any>>
                let i_id = tmp[0]["DeviceIdentifier"] as! String
                if i_id == _id {
                    dict.updateValue(i["DeviceIdentifier"] as! String, forKey: "map")
                    var dict_tmp = [Dictionary<String,String>]()
                    for l in i["APFSVolumes"] as! Array<Dictionary<String,Any>> {
                        var tmp_name = l["DeviceIdentifier"] as! String
                        var tmp_group = [
                            "id":l["DeviceIdentifier"] as! String,
                            "name":tmp_name
                        ]
                        if let tmp_name = l["VolumeName"] {
                            tmp_group["name"] = tmp_name as? String
                        }
                        dict_tmp.append(tmp_group)
                    }
                    dict.updateValue(dict_tmp, forKey: "part")
                }
            }
        }
        return dict
    }
}
