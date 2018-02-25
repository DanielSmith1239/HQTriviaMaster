//
//  HQWebSocketDelegate.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/23/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

protocol HQWebSocketDelegate
{
    func recievedQuestion(hqQuestion: HQQuestion)
    func broadcastStarted()
    func broadcastEnded()
}
