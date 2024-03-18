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
    let pipe = Pipe()
    diskutil.standardOutput = pipe
    try! diskutil.run()
    diskutil.waitUntilExit()
    let disks_text = (try! pipe.fileHandleForReading.readToEnd())!
    let data = (try? PropertyListSerialization.propertyList(from: disks_text, format: nil) as? Dictionary<String,Any>)!
    return data
}
class Disk: ObservableObject{
    @Published var all_disks =  get_all_disks()
    @Published var whole_disks:Array<String>
    @Published var all_disks_and_partitions:Array<Dictionary<String,Any>>
    @Published var main_disk=[
        "in":Array<Dictionary<String,String>>(),
        "extra":Array<Dictionary<String,String>>(),
        "disk":Array<Dictionary<String,String>>()
    ]
    @Published var build_index:Array<Dictionary<String,Any>>=[]
    init() {
        self.whole_disks = self.all_disks["WholeDisks"] as! Array<String>
        self.all_disks_and_partitions = self.all_disks["AllDisksAndPartitions"] as! Array<Dictionary<String,Any>>
        for i in self.whole_disks{
            let detail = get_disk_detail(id: i)
            if detail["APFSPhysicalStores"] == nil && detail["Internal"] as! Bool{
                let tmp = [
                    "id":i,
                    "name":detail["MediaName"] as! String
                ]
                main_disk["in"]!.append(tmp)
            } else if detail["APFSPhysicalStores"] == nil && detail["BusProtocol"] as! String == "USB"{
                let tmp = [
                    "type":"extra",
                    "id":i,
                    "name":detail["MediaName"] as! String
                ]
                main_disk["extra"]!.append(tmp)
            } else if detail["APFSPhysicalStores"] == nil && detail["BusProtocol"] as! String == "Disk Image"{
                let tmp = [
                    "type":"disk",
                    "id":i,
                    "name":detail["MediaName"] as! String
                ]
                main_disk["disk"]!.append(tmp)
            }
        }
        self.build_disks_index()
    }
    func update(){
        self.all_disks = get_all_disks()
        self.whole_disks = self.all_disks["WholeDisks"] as! Array<String>
        self.all_disks_and_partitions = self.all_disks["AllDisksAndPartitions"] as! Array<Dictionary<String,Any>>
        self.build_disks_index()
    }
    func build_disks_index(){
        for i in self.main_disk["in"]! + self.main_disk["extra"]! + self.main_disk["disk"]!{
            self.build_index.append(simplify(_id: i["id"]!))
        }
    }
    func simplify(_id:String) -> Dictionary<String,Any>{
        var tmp = [String:Any]()
        for i in self.all_disks_and_partitions{
            if i["DeviceIdentifier"] as! String == _id {
                tmp.updateValue([String:Any](), forKey: _id)
                var dict = tmp[_id] as! Dictionary<String,Any>
                for l in i["Partitions"] as! Array<Dictionary<String,Any>>{
                    var sub_items = simplify_sub(_id: l["DeviceIdentifier"] as! String)
                    var tmp_name = ""
                    if l["VolumeName"] != nil {
                        tmp_name = l["VolumeName"] as! String
                    }
                    sub_items.updateValue(tmp_name, forKey: "name")
                    dict.updateValue(sub_items, forKey: l["DeviceIdentifier"] as! String)
                }
                tmp[_id] = dict
            }
        }
        return tmp
    }
    func simplify_sub(_id:String) -> Dictionary<String,Any>{
        var dict = [String:Any]()
        for i in self.all_disks_and_partitions{
            if i["APFSPhysicalStores"] != nil {
                let tmp = i["APFSPhysicalStores"] as! Array<Dictionary<String,Any>>
                let i_id = tmp[0]["DeviceIdentifier"] as! String
                if i_id == _id {
                    dict.updateValue(i["DeviceIdentifier"] as! String, forKey: "map")
                    var dict_tmp = [Dictionary<String,String>]()
                    for l in i["APFSVolumes"] as! Array<Dictionary<String,Any>> {
                        var tmp_name = l["DeviceIdentifier"] as! String
                        if l["VolumeName"] != nil {
                            tmp_name = l["VolumeName"] as! String
                        }
                        let tmp_group = [
                            "id":l["DeviceIdentifier"] as! String,
                            "name":tmp_name
                        ]
                        dict_tmp.append(tmp_group)
                    }
                    dict.updateValue(dict_tmp, forKey: "part")
                }
            }
        }
        return dict
    }
}
