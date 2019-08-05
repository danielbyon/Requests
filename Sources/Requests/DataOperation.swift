//
//  DataOperation.swift
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

open class DataOperation<T: DataRequest>: NetworkOperation<T> {
    
    // MARK: Variables

    private var dataTask: URLSessionDataTask?
    
    // MARK: Operation Lifecycle

    open override func main() {
        request.makeURLRequest { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let urlRequest):
                self.urlRequest = urlRequest
                self.startDataTask(with: urlRequest)
            case .failure(let error):
                self.result = .failure(self.request.mapError(error))
            }
        }
    }

    open override func cancel() {
        super.cancel()
        dataTask?.cancel()
        dataTask = nil
    }
    
    // MARK: Private
    
    private func startDataTask(with urlRequest: URLRequest) {
        guard !isCancelled else {
            return
        }
        dataTask = self.session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            defer {
                self.dataTask = nil
            }

            self.urlResponse = response

            guard !self.isCancelled else {
                return
            }

            if let error = error {
                self.result = .failure(self.request.mapError(error))
                return
            }

            if let response = response as? HTTPURLResponse {
                guard self.request.validHTTPStatusCodes.contains(response.statusCode) else {
                    self.result = .failure(self.request.mapError(RequestQueueError.invalidStatusCode(statusCode: response.statusCode)))
                    return
                }
            }

            do {
                guard let data = data else {
                    self.result = .failure(self.request.mapError(RequestQueueError.didNotReceiveData))
                    return
                }

                guard !self.isCancelled else {
                    return
                }

                let processed = try self.request.processData(data)
                self.result = .success(processed)
            } catch {
                self.result = .failure(self.request.mapError(error))
            }
        }
        dataTask?.resume()
    }

}
