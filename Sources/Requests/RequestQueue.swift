//
//  RequestQueue.swift
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

// MARK: - RequestQueue
public protocol RequestQueue {

    @discardableResult
    func addRequest<T: DataRequest>(_ request: T, completion: T.CompletionType?) -> Operation

    @discardableResult
    func addRequest<T: DataRequest>(_ request: T, session: URLSession, completion: T.CompletionType?) -> Operation

    @discardableResult
    func addRequest<T: DataRequest>(_ request: T, session: URLSession, completionQueue: DispatchQueue?, completion: T.CompletionType?) -> Operation

    func requestCurrentlyExecuting<T: Request>(_ request: T) -> Operation?

}

// MARK: Overloaded Implementations
public extension RequestQueue {
    
    // Swift does not allow default parameter arguments in protocol method declarations, so we have to use overloaded methods instead.

    @discardableResult
    func addRequest<T: DataRequest>(_ request: T, completion: T.CompletionType?) -> Operation {
        return addRequest(request, session: .shared, completionQueue: nil, completion: completion)
    }

    @discardableResult
    func addRequest<T: DataRequest>(_ request: T, session: URLSession, completion: T.CompletionType?) -> Operation {
        return addRequest(request, session: session, completionQueue: nil, completion: completion)
    }

}

// MARK: - OperationQueue
extension OperationQueue: RequestQueue {

    @discardableResult
    open func addRequest<T: DataRequest>(_ request: T, session: URLSession, completionQueue: DispatchQueue?, completion: T.CompletionType?) -> Operation {
        let operation = addRequestOperation(for: request, session: session, completionQueue: completionQueue, completion: completion)
        return operation
    }

    open func requestCurrentlyExecuting<T: Request>(_ request: T) -> Operation? {
        return operations.compactMap { $0 as? RequestQueueOperation<T> }
            .first { !$0.isFinished && $0.request.identifier == request.identifier }
    }
    
}

// MARK: - Private
private extension OperationQueue {

    func addRequestOperation<T: DataRequest>(for request: T, session: URLSession, completionQueue: DispatchQueue?, completion: T.CompletionType?) -> Operation {
        let operation = DataOperation(request: request, session: session)
        operation.completionBlock = { [weak operation] in
            guard let result = operation?.result else {
                return
            }
            
            if let completionQueue = completionQueue {
                completionQueue.async {
                    completion?(result)
                }
            } else {
                // Didn't specify a queue, run it on global utility
                DispatchQueue.global(qos: .utility).async {
                    completion?(result)
                }
            }
        }
        addOperation(operation)
        return operation
    }

}
