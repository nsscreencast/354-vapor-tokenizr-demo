import Vapor
import Foundation

struct TokenizeResponse : Encodable {
    var text: String
    var matches: [String]
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req -> Future<View> in
        return try req.view().render("home")
    }
    
    router.post("tokenize") { req -> Future<View> in
        let text: String = try req.content.syncGet(at: "text")
        
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        
        var matches: [String] = []
        tagger.enumerateTags(in: range, scheme: .nameType, options: options) { tag, tokenRange, _, _ in
            
            if let tag = tag, tags.contains(tag) {
                let tagString = (text as NSString).substring(with: tokenRange)
                matches.append(tagString)
            }
        }
        
        let context = TokenizeResponse(text: text, matches: matches)
        
        return try req.view().render("home", context)
    }
}
