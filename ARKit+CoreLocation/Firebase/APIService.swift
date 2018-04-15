//
//  FirebaseAPIService.swift
//  Balizinha
//
//  Created by Ren, Bobby on 2/25/18.
//  Copyright © 2018 Bobby Ren. All rights reserved.
//

import UIKit

class APIService: NSObject {
    // variables for creating customer key
    let opQueue = OperationQueue()
    var urlSession: URLSession?
    var dataTask: URLSessionTask?
    var data: Data?
    
    typealias cloudCompletionHandler = ((_ response: Any?, _ error: Error?) -> ())
    var completionHandler: cloudCompletionHandler?
    
    override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: self.opQueue)
    }

    var baseURL: URL? {
        return URL(string: "https://codefest2018.herokuapp.com/")
    }

    func test() {
        let urlString = "https://codefest2018.herokuapp.com/event"
        guard let requestUrl = URL(string:urlString) else { return }
        var request = URLRequest(url:requestUrl)
        
        let params = ["uid": "123", "email": "test@gmail.com"]
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        try! request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func cloudFunction(id: String, functionName: String, method: String = "POST", params: [String: Any]?, completion: cloudCompletionHandler?) {
        guard let url = self.baseURL?.appendingPathComponent(id).appendingPathComponent(functionName) else {
            completion?(nil, nil) // todo
            return
        }
        var request = URLRequest(url:url)
        request.httpMethod = method
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        if let params = params {
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch let error {
                print("FirebaseAPIService: cloudFunction could not serialize params: \(params) with error \(error)")
            }
        }
        
        self.completionHandler = completion
        
        let task = urlSession?.dataTask(with: request)
        task?.resume()
    }
}

extension APIService: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //print("FirebaseAPIService: data received")
        if let data = self.data {
            self.data?.append(data)
        }
        else {
            self.data = data
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //print("FirebaseAPIService: completed")
        defer {
            self.data = nil
            self.completionHandler = nil
        }
        
        let response: HTTPURLResponse? = task.response as? HTTPURLResponse
        let statusCode = response?.statusCode ?? 0
        
        if let usableData = self.data {
            do {
                let json = try JSONSerialization.jsonObject(with: usableData, options: []) as? [String: Any]
                //print("FirebaseAPIService: urlSession completed with json \(json)")
                if statusCode >= 300 {
                    completionHandler?(nil, NSError(domain: "balizinha", code: statusCode, userInfo: json))
                } else {
                    completionHandler?(json, nil)
                }
            } catch let error {
                print("FirebaseAPIService: JSON parsing resulted in error \(error)")
                let dataString = String.init(data: usableData, encoding: .utf8)
                print("StripeService: try reading data as string: \(dataString)")
                completionHandler?(nil, error)
            }
        }
        else if let error = error {
            completionHandler?(nil, error)
        }
        else {
            print("here")
        }
    }
}
