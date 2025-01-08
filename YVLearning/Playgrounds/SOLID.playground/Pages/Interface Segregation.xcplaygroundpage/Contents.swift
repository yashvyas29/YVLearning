//: The Interface Segregation Principle

//: [Previous](@previous)

import UIKit

//MARK: - Fat Protocol

protocol ImageProtocol {
    var base64Encoded: String { get }
    var jpegData: Data? { get}
    var pngData: Data? { get }

    init(data: Data)
    
    init(from url: URL) throws
    func save(to url: URL) throws
}


//MARK: - Segregated Protocols

protocol ImageProtocol {
    var data: Data { get }
    init(data: Data)
}

protocol Base64Encoding: ImageProtocol {
    var base64Encoded: String { get }
}

protocol ImageEncoding: ImageProtocol {
    var jpegData: Data? { get}
    var pngData: Data? { get }
}

protocol ImagePersistence: ImageProtocol {
    func load(from url: URL) -> Self?
    func save(to url: URL) throws
}


//MARK: - Default behavior implemented in extensions

extension Base64Encoding {
    var base64Encoded: String {
        return self.data.base64EncodedString()
    }
}

extension ImageEncoding {
    var jpegData: Data? {
        guard let uiImage = UIImage.init(data: self.data),
              let jpegData = uiImage.jpegData(compressionQuality: 1) else {
            return nil
        }
        return jpegData
    }

    var pngData: Data? {
        guard let uiImage = UIImage.init(data: self.data),
              let pngData = uiImage.pngData() else {
            return nil
        }
        return pngData
    }
}


// MARK: - Adopters

class EncodableImage: ImageEncoding {
    var data: Data

    required init(data: Data) {
        self.data = data
    }
}

class Base64EncodablePersistableImage: Base64Encoding, ImageEncoding {
    var data: Data

    required init(data: Data) {
        self.data = data
    }
}

//: [Next](@next)
