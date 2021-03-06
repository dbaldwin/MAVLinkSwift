//
//  UDPReceiver.swift
//  MAVLinkSwift
//
//  Created by Dennis Baldwin on 1/28/19.
//  Copyright © 2019 Unmanned Airlines, LLC. All rights reserved.
//

import Foundation
import SwiftSocket
import Mavlink

class UDPReceiver {
    
    let host: String
    let port: Int32
    var receiver: UDPServer
    
    init(host: String, port: Int32) {
        self.host = host
        self.port = port
        self.receiver = UDPServer(address: self.host, port: self.port)
    }
    
    public func listenForData() {
        DispatchQueue.global(qos: .background).async {
            while true {
                let response = self.receiver.recv(512)
                self.parseMavMessage(message: response.0!)
            }
        }
    }
    
    private func parseMavMessage(message: [Byte]) {
        let data: Data = Data(bytes: message)
        let bytes: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: data.count)
        data.copyBytes(to: bytes, count: data.count)
        
        for index in 0..<data.count {
            let byte: UInt8 = (bytes + index).pointee
            var message = mavlink_message_t()
            var status = mavlink_status_t()
            let channel = UInt8(MAVLINK_COMM_1.rawValue)
            
            if mavlink_parse_char(channel, byte, &message, &status) != 0 {
                print(message)
            }
        }
    }
    
    public func destroy() {
        self.receiver.close()
    }
}

extension mavlink_message_t: CustomStringConvertible {
    public var description: String {
        var message = self
        switch msgid {
        case 0:
            var heartbeat = mavlink_heartbeat_t()
            mavlink_msg_heartbeat_decode(&message, &heartbeat)
            return "HEARTBEAT mavlink_version: \(heartbeat)\n"
        case 1:
            var sys_status = mavlink_sys_status_t()
            mavlink_msg_sys_status_decode(&message, &sys_status)
            return "SYS_STATUS comms drop rate: \(sys_status.drop_rate_comm)%\n"
        case 24:
            let gps = mavlink_gps_raw_int_t()
            return "GPS_RAW_INT lat: \(gps.lat) lng: \(gps.lon) alt: \(gps.alt)"
        case 30:
            var attitude = mavlink_attitude_t()
            mavlink_msg_attitude_decode(&message, &attitude)
            return "ATTITUDE roll: \(attitude.roll) pitch: \(attitude.pitch) yaw: \(attitude.yaw)\n"
        case 32:
            return "LOCAL_POSITION_NED\n"
        case 33:
            return "GLOBAL_POSITION_INT\n"
        case 65:
            return "RC_CHANNELS"
        case 74:
            var vfr_hud = mavlink_vfr_hud_t()
            mavlink_msg_vfr_hud_decode(&message, &vfr_hud)
            return "VFR_HUD heading: \(vfr_hud.heading) degrees\n"
        case 87:
            return "POSITION_TARGET_GLOBAL_INT\n"
        case 105:
            var highres_imu = mavlink_highres_imu_t()
            mavlink_msg_highres_imu_decode(&message, &highres_imu)
            return "HIGHRES_IMU Pressure: \(highres_imu.abs_pressure) millibar\n"
        case 109:
            return "RADIO_STATUS"
        case 125:
            return "POWER_STATUS"
        case 141:
            let altitude = mavlink_altitude_t()
            return "ALTITUDE: \(altitude)"
        case 147:
            var battery_status = mavlink_battery_status_t()
            mavlink_msg_battery_status_decode(&message, &battery_status)
            return "BATTERY_STATUS current consumed: \(battery_status.current_consumed) mAh\n"
        case 241:
            let vibration = mavlink_vibration_t()
            return "VIBRATION: \(vibration)"
        case 242:
            let home = mavlink_home_position_t()
            return "HOME_POSITION: lat: \(home.latitude) lon: \(home.longitude) alt: \(home.altitude)"
        default:
            return "OTHER Message id \(message.msgid) received\n"
        }
    }
}
