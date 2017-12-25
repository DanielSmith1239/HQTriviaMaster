//
//  DiffenController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/9/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
import Fuzi

class DiffenController
{
    static func getMatchesForComparison(_ question: String, for options: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var compared = [false, false, false]
        var searchStrings = TextController.getSearchWords(forQuestion: question)
        for term in comparisonType.getCompTerms()
        {
            if searchStrings.contains(term)
            {
                let i = searchStrings.index(of: term)!
                searchStrings = Array(searchStrings.suffix(i))
            }
        }
        for op in options
        {
            WebAPIController.getDiffenPage(for: op)
            {
                page in
                
                do
                {
                    let doc = try HTMLDocument(string: page)
                    print(doc.xpath("//table").first)
                }
                catch
                {
                    print(error)
                }
            }
        }
        
    }
    
    enum comparisonType
    {
        case most
        case least
        
        static func getCompTerms() -> [String] { return getMostTerms() + getLeastTerms() }
        
        private static func getMostTerms() -> [String] { return ["most", "best", "highest"] }
        private static func getLeastTerms() -> [String] { return ["least", "worst", "lowest"] }
        
        static func getTypeForWord(_ str: String) -> comparisonType
        {
            for word in getLeastTerms()
            {
                if str.contains(word)
                {
                    return .least
                }
            }
            return .most
        }
    }
}
