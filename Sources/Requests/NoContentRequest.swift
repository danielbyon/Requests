//
//  NoContentRequest.swift
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

public protocol NoContentRequest: DataRequest where Success == Void {

    /// An error will be thrown if this is `true`, and the response contains non-empty data.
    var shouldEnforceNoContent: Bool { get }
    
}

public extension NoContentRequest {

    var shouldEnforceNoContent: Bool {
        return true
    }
    
    var validHTTPStatusCodes: [Int] {
        return [204]
    }
    
    func processData(_ data: Data) throws -> Success {
        if !data.isEmpty && shouldEnforceNoContent {
            // If this is truly a "no content" request, it should not receive data in the response.
            throw RequestQueueError.nonEmptyData
        }
        return ()
    }
    
}
