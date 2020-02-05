//
//  AdharaSocket.swift
//  adhara_socket_io
//
//  Created by soumya thatipamula on 19/11/18.
//

import Foundation


import Flutter
import UIKit
import SocketIO


public class AdharaSocket: NSObject, FlutterPlugin {
    
    let socket: SocketIOClient
    let channel: FlutterMethodChannel
    let manager: SocketManager
    let config: AdharaSocketIOClientConfig
    
    private func log(_ items: Any...){
        if(config.enableLogging){
            print(items)
        }
    }

    public init(_ channel:FlutterMethodChannel, _ config:AdharaSocketIOClientConfig) {
        manager = SocketManager(socketURL: URL(string: config.uri)!, config: [.log(true), .connectParams(config.query), .forceWebsockets(true)])
        socket = manager.defaultSocket
        self.channel = channel
        self.config = config
    }

    public static func getInstance(_ registrar: FlutterPluginRegistrar, _ config:AdharaSocketIOClientConfig) ->  AdharaSocket{
        let channel = FlutterMethodChannel(name: "adhara_socket_io:socket:"+String(config.adharaId), binaryMessenger: registrar.messenger())
        let instance = AdharaSocket(channel, config)
        instance.log("initializing with URI", config.uri)
        registrar.addMethodCallDelegate(instance, channel: channel)
        return instance
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var arguments: [String: AnyObject]
        if(call.arguments != nil){
            arguments = call.arguments as! [String: AnyObject]
        }else{
            arguments = [String: AnyObject]()
        }
        switch call.method{
            case "connect":
                socket.on(clientEvent: .connect) {data, ack in
                    print("socket connected")
                }
                socket.connect()
                self.log("connecting... on swift")
                result(nil)
            case "on":
                let eventName: String = arguments["eventName"] as! String
                self.log("registering event:::", eventName)
                socket.on(eventName) {data, ack in
                    self.log("incoming:::", eventName, data, ack)
                    var list = [String]()
                    for item in data {
                        list.append(item as! String)
                    }
                    self.channel.invokeMethod("incoming", arguments: [
                        "eventName": eventName,
                        "args": list
                    ]);
                }
                result(nil)
            case "off":
                let eventName: String = arguments["eventName"] as! String
                self.log("un-registering event:::", eventName)
                socket.off(eventName);
                result(nil)
            case "emit":
                let eventName: String = arguments["eventName"] as! String
                let data: [String:AnyObject] = arguments["arguments"] as! [String: AnyObject]
                self.log("emitting:::", data, ":::to:::", eventName, data);
                
                socket.emit(eventName, data) 
                result(nil)
//                socket.emitWithAck(eventName, data)
//                    .timingOut(after: 0, callback: {args in
//                        if(eventName == "message" && args.count > 0) {
//                            result(args[args.count - 1]);
//                        } else {
//                            result(nil)
//                        }
//                    })
            case "isConnected":
                self.log("connected")
                result(socket.status == .connected)
            case "disconnect":
                self.log("dis-connected")
                socket.disconnect()
                result(nil)
            default:
                result(FlutterError(code: "404", message: "No such method", details: nil))
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        //        Do nothing...
    }
    
}

public class AdharaSocketIOClientConfig: NSObject{
    
    let adharaId:Int
    let uri:String
    public var query:[String:String]
    public var enableLogging:Bool
    
    init(_ adharaId:Int, uri:String) {
        self.adharaId = adharaId
        self.uri = uri
        self.query = [String:String]()
        self.enableLogging = false
    }
    
}
