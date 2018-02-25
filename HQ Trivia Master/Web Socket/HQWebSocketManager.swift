//
//  WebSocketController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/20/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation
import SwiftWebSocket

class HQWebSocketManager
{
    var delegate: HQWebSocketDelegate!
    
    func connectToHQSocket(url: URL)
    {
        let credentials = SiteEncoding.hqCredentials
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.addValue("iPhone/11.2.5", forHTTPHeaderField: "x-hq-client")
        let token = credentials.token!.contains("Bearer ") ? credentials.token! : "Bearer \(credentials.token ?? "")"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("MQ==", forHTTPHeaderField: "x-hq-stk")
        request.addValue("api-quiz.hype.space", forHTTPHeaderField: "Host")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("okhttp/3.8.0", forHTTPHeaderField: "User-Agent")

        let socket = WebSocket(request: request)

        socket.event.open = {
            print("Opened web socket.")
            self.delegate.broadcastStarted()
        }
        
        socket.event.error = { error in
            print("Error: \(error)")
            self.delegate.broadcastEnded()
        }
        
        socket.event.message = { message in
            if let msgString = message as? String,
                let data = msgString.data(using: .utf8),
                let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any],
                let type = json["type"] as? String
            {
                if type == "question"
                {
                    self.delegate.recievedQuestion(hqQuestion: (HQQuestion(json)))
                }
                else if type == "broadcastEnded"
                {
                    socket.close()
                    self.connectToHQSocket(url: url)
                }
            }
        }
    }
}
