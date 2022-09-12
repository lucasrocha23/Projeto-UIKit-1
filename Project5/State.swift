//
//  State.swift
//  Challeng4c
//
//  Created by Lucas Rocha on 28/09/22.
//

import UIKit

class State: NSObject, Codable {
    var userWords = [String]()
    var currentWord : String
    var score : Int
    var highscore : Int
    
    
    override init(){
        self.userWords = [String]()
        self.currentWord = ""
        self.score = 0
        self.highscore = 0
    }
}
