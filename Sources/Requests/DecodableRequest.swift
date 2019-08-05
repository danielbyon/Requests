//
//  DecodableRequest.swift
//  Requests
//
//  Created by Daniel Byon on 8/5/19.
//  Copyright 2019 Daniel Byon.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

public protocol DecodableRequest: DataRequest where Success: Decodable {

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? { get }

    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }

    var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? { get }

    var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? { get }

}

public extension DecodableRequest {

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? {
        return nil
    }

    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? {
        return nil
    }

    var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? {
        return nil
    }

    var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? {
        return nil
    }
    
    func processData(_ data: Data) throws -> Success {
        let decoder = JSONDecoder()
        if let keyDecodingStrategy = keyDecodingStrategy {
            decoder.keyDecodingStrategy = keyDecodingStrategy
        }
        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }
        if let dataDecodingStrategy = dataDecodingStrategy {
            decoder.dataDecodingStrategy = dataDecodingStrategy
        }
        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }
        
        let retVal = try decoder.decode(Success.self, from: data)
        return retVal
    }

}
