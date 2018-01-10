//
//  Extensions.swift
//  HQ Trivia Master
//
//  Created by Michael Schloss on 12/30/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa

///Stores information on the number of times a string is seen
struct AnswerCounts : CustomStringConvertible, CustomDebugStringConvertible
{
    private var innerRepresentation = [String : Int]()
    
    var isOpposite = false
    
    subscript(key: String) -> Int
    {
        get
        {
            return innerRepresentation[key] ?? 0
        }
        set
        {
            innerRepresentation[key] = newValue
        }
    }
    
    ///Returns the number of strings
    var count : Int
    {
        return innerRepresentation.count
    }
    
    var sumOfResults : Int
    {
        var sum = 0
        for integer in innerRepresentation.map({ return $1 })
        {
            sum += integer
        }
        return sum
    }
    
    var dump : [(String, Int)]
    {
        return innerRepresentation.map({ return ($0, $1) })
    }
    
    ///Returns the String and visibility count with the largest visibility count
    var largest : (String, Int)
    {
        var max = ("", Int.min)
        for (key, value) in innerRepresentation
        {
            if value >= max.1
            {
                max = (key, value)
            }
        }
        return max
    }
    
    ///Returns the String and visibility count with the smallest visibility count
    var smallest : (String, Int)
    {
        var min = ("", Int.max)
        for (key, value) in innerRepresentation
        {
            if value <= min.1
            {
                min = (key, value)
            }
        }
        return min
    }
    
    ///Returns how many times a certain visiblity count is witnessed
    var countsOfResults : [Int : Int]
    {
        var counts = [Int : Int]()
        for (_, value) in innerRepresentation
        {
            counts[value, default: 0] += 1
        }
        return counts
    }
    
    var description: String
    {
        var string = ""
        for (key, value) in innerRepresentation
        {
            string += "\(key): \(value)\n"
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var debugDescription: String
    {
        var string = ""
        string += "Largest Result: \(largest.1)\n"
        string += "Smallest Result: \(largest.1)\n"
        string += description + "\n"
        string += "Is inverted: \(isOpposite)\n"
        string += "Counts of results:\n"
        for (key, value) in countsOfResults
        {
            string += "\(key): \(value)\n"
        }
        return string
    }
}

///A struct that specifies a search string and replacement string
private struct Replacement
{
    let search : String
    let replacement : String
    
    init(search: String, replacement: String)
    {
        self.search = search
        self.replacement = replacement
    }
}

//Just gives quicker access to lowercasing items
private extension Array where Element : StringProtocol
{
    var lowercased : [String]
    {
        var returnArray = [String]()
        for element in self
        {
            returnArray.append((element as? String)?.lowercased() ?? "")
        }
        return returnArray
    }
}

//Quick formatting for decimal numbers
extension CGFloat
{
    func format(f: String) -> String
    {
        return String(format: "%\(f)f", self)
    }
}

//Borrowed from https://stackoverflow.com/a/36006764
extension NSWindow
{
    /**
     Shakes an NSWindow to simulate an error response á la Login window
     - Parameter intensity: The intensity with which to shake
     - Parameter duration: How long the shake should last
     */
    func shake(with intensity: CGFloat = 0.02, duration: Double = 0.3)
    {
        if animations.isEmpty
        {
            let numberOfShakes = 3
            let frame = self.frame
            let shakeAnimation = CAKeyframeAnimation()
            
            let shakePath = CGMutablePath()
            shakePath.move(to: CGPoint(x: frame.minX, y: frame.minY))
            
            for _ in 0...numberOfShakes - 1
            {
                shakePath.addLine(to: CGPoint(x: frame.minX - frame.size.width * intensity, y: frame.minY))
                shakePath.addLine(to: CGPoint(x: frame.minX + frame.size.width * intensity, y: frame.minY))
            }
            
            shakePath.closeSubpath()
            shakeAnimation.path = shakePath
            shakeAnimation.duration = duration
            
            animations = [NSAnimatablePropertyKey(rawValue: "frameOrigin") : shakeAnimation]
        }
        animator().setFrameOrigin(self.frame.origin)
    }
}

extension String
{
    ///A list of words to remove from the search
    private var extraneousWords : [String]
    {
        return [" of these ", " his ", " is ", " her ", " their ", " in ", " from ", " was ", " which ", "?", "\"", " or ", " a ", " an ", " of ", " the ", " that ", " what ", " to ", " for ", " only ", " not ", " does ", " NOT ", " would ", " you ", " need ", " at ", "On ", " find ", " all time ", "Which ", "What is ","What ",  "For", "also", "with"]
    }
    
    ///Returns `true` if `self` contains any word listed in the `extraneousWords` parameter, `false` otherwise
    var hasExtraneousWords : Bool
    {
        let lowercasedExtraneous = extraneousWords.lowercased
        for word in self.components(separatedBy: " ")
        {
            if lowercasedExtraneous.contains(word)
            {
                return true
            }
        }
        return false
    }
    
    ///Returns a string after stripping out any word listed in the `extraneousWords` parameter
    var withoutExtraneousWords : String
    {
        var question = self
        extraneousWords.forEach { question = $0.first == " " ? question.replacingOccurrences(of: $0, with: " ") : question.replacingOccurrences(of: $0, with: "") }
        question = question.replacingOccurrences(of: "  ", with: " ")
        return question
    }
    
    ///Returns a string formatted for Google
    var googleOption : String
    {
        var ret = self
        for str in Google.removeFromOption
        {
            ret = ret.replacingOccurrences(of: str, with: "")
        }
        return ret.replacingOccurrences(of: "  ", with: " ")
    }
    
    /**
     Returns a bool determining whether at least one element in the speicifed collection is contained in `self`
     - Parameter collection: An array of strings to search for
     - Returns: `true` if any string in `collection` is present in `self`, false otherwise
    */
    func contains(atLeastOneElementIn collection: [String]) -> Bool
    {
        for str in collection
        {
            if contains(str)
            {
                return true
            }
        }
        return false
    }
    
    ///Returns a list of words in `self` that are not included in the `extraneousWords` parameter
    var searchWords : [String]
    {
        let trimmedQuestion = withoutExtraneousWords
        return trimmedQuestion.split(separator: " ").map { String($0) }
    }
    
    /**
     URL Encodes a string
     
     **Programmer Notes:** This method may need to be modified with each new SiteEncoding added
     - Parameter siteEncoding: A `SiteEncoding` by which to encode a string
     - Returns: A URL encoded version of `self`
     */
    func urlEncoded(for siteEncoding: SiteEncoding) -> String?
    {
        switch siteEncoding
        {
        case .google:
            let punctuationToRemove = ["\"", "\\", "“", "”", "?", "#", "&", ".", ",", "’", "”", "“"]
            let punctuationToReplace = ["  ", " "]
            var fixed = strippingIllegalCharacters
            
            if fixed.contains(".")
            {
                var words = fixed.components(separatedBy: " ")
                for (i, word) in words.enumerated()
                {
                    if word.contains(".")
                    {
                        let temp = word.replacingOccurrences(of: ".", with: "")
                        words[i] = temp
                    }
                    else
                    {
                        words[i] = "intext:\(word) "
                    }
                }
                fixed = words.joined(separator: " ")
            }
            else
            {
                fixed = fixed.withoutExtraneousWords
            }
            
            for item in punctuationToReplace
            {
                fixed = fixed.replacingOccurrences(of: item, with: "+")
            }
            for item in punctuationToRemove
            {
                fixed = fixed.replacingOccurrences(of: item, with: "")
            }
            fixed = fixed.replacingOccurrences(of: "+intext:+", with: "+").replacingOccurrences(of: "++", with: "+")
            if fixed.hasSuffix("+") { fixed.removeLast() }
            return fixed
        default:
            return nil
        }
    }
    
    ///Returns a copy of `self` in which certain text elements created from Tesseract are replaced
    var fixedText : String
    {
        let replacementArray = [Replacement(search: "'s", replacement: ""), Replacement(search: "ﬁ", replacement: "fi"), Replacement(search: "|", replacement: "I"), Replacement(search: "vv", replacement: "w"), Replacement(search: "VV", replacement: "W"), Replacement(search: "é", replacement: "e"), Replacement(search: "ﬂ", replacement: "tl"), Replacement(search: "re-", replacement: "re"), Replacement(search: "-", replacement: ""), Replacement(search: ":8", replacement: "&"), Replacement(search: "05", replacement: "0s")]
        var returnString = self
        for item in replacementArray
        {
            returnString = returnString.replacingOccurrences(of: item.search, with: item.replacement)
        }
        return returnString
    }
    
    ///Returns a copy of `self` by stripping out invalid characters
    var strippingIllegalCharacters : String
    {
        let legalCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890&-_. ").inverted
        return fixedText.trimmingCharacters(in: legalCharacters)
    }
}
