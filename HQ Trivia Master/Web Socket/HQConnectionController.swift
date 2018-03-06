//
//  HQConnectionController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/20/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

class HQConnectionController
{
    var delegate: HQWebSocketDelegate!
    private var shouldCheck = false
    
    func beginCheckingForHQGame()
    {
        shouldCheck = true
        checkForHqGame()
    }
    
    func stopCheckingForHQGame()
    {
        shouldCheck = false
    }
    
    func shouldCheckForHQGame(shouldCheckForGame check: Bool)
    {
        shouldCheck = check
        if check { checkForHqGame() }
    }
    
    private func checkForHqGame()
    {
        print("checking...")
        getHQGameDetails() { retGame in
            guard let game = retGame, game.active == true, let broadcast = game.broadcast, let socketUrl = broadcast.socketUrl else
            {
                if self.shouldCheck
                {
                    sleep(5)
                    self.checkForHqGame()
                }
                return
            }
            
            print("Found socket url.")
            
            if self.shouldCheck
            {
                let socketManager = HQWebSocketManager()
                socketManager.delegate = self.delegate
                socketManager.connectToHQSocket(url: socketUrl)
            }
        }
    }
    
    private func getHQGameDetails(completion: @escaping (_ game: HQGame?) -> ())
    {
        let credentials = SiteEncoding.hqCredentials
        let url = URL(string: "https://api-quiz.hype.space/shows/now?type=hq&userId=\(credentials.username ?? "")")!
        guard let tokenString = credentials.token else
        {
            return
        }
        let token = tokenString.contains("Bearer ") ? tokenString : "Bearer \(tokenString)"
        
        var request = URLRequest(url: url)
        request.addValue("iPhone/11.2.5", forHTTPHeaderField: "x-hq-client")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error
            {
                print(error)
                completion(nil)
                return
            }
            guard let pageData = data else
            {
                completion(nil)
                return
            }
            do
            {
                guard let json = try JSONSerialization.jsonObject(with: pageData, options: []) as? [String: Any] else
                {
                    completion(nil)
                    return
                }
                completion(HQGame(json))
            }
            catch
            {
                print(error)
                completion(nil)
            }
        }.resume()
    }
}
