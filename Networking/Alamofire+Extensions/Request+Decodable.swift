//
//  SeesionManager+Extension.swift
//  OAuthTest
//
//  Created by Michal Štembera on 05/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//
//  Using same formatting as Alamofire so silence warnings
//  swiftlint:disable opening_brace

import Foundation
import Alamofire

// MARK: - Default Alamofire JSONDecoder
public extension JSONDecoder {
    static var alamofire: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: - Request
extension Request {
    public static func serializeResponseDecodable<Value>(
        decoder: JSONDecoder,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Alamofire.Result<Value> where Value: Decodable
    {
        guard error == nil else { return .failure(error!) }

        guard let validData = data, validData.count > 0 else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }

        do {
            let value = try decoder.decode(Value.self, from: validData)
            return .success(value)
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}

// MARK: - DataRequest
extension DataRequest {
    public static func decodableResponseSerializer<Value>(
        decoder: JSONDecoder)
        -> DataResponseSerializer<Value> where Value: Decodable
    {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseDecodable(decoder: decoder,
                                                      response: response,
                                                      data: data,
                                                      error: error)
        }
    }

    @discardableResult
    public func responseDecodable<Value>(
        queue: DispatchQueue? = nil,
        type: Value.Type,
        decoder: JSONDecoder = .alamofire,
        completionHandler: @escaping (DataResponse<Value>) -> Void)
        -> Self where Value: Decodable
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.decodableResponseSerializer(decoder: decoder),
            completionHandler: completionHandler
        )
    }
}

// MARK: - DownloadRequest
extension DownloadRequest {
    public static func decodableResponseSerializer<Value>(
        decoder: JSONDecoder)
        -> DownloadResponseSerializer<Value> where Value: Decodable
    {
        return DownloadResponseSerializer { _, response, fileURL, error in
            guard error == nil else { return .failure(error!) }

            guard let fileURL = fileURL else {
                return .failure(AFError.responseSerializationFailed(reason: .inputFileNil))
            }

            do {
                let data = try Data(contentsOf: fileURL)
                return Request.serializeResponseDecodable(decoder: decoder,
                                                          response: response,
                                                          data: data,
                                                          error: error)
            } catch {
                return .failure(AFError.responseSerializationFailed(reason: .inputFileReadFailed(at: fileURL)))
            }
        }
    }

    @discardableResult
    public func responseDecodable<Value>(
        queue: DispatchQueue? = nil,
        type: Value.Type,
        decoder: JSONDecoder = .alamofire,
        completionHandler: @escaping (DownloadResponse<Value>) -> Void)
        -> Self where Value: Decodable
    {
        return response(
            queue: queue,
            responseSerializer: DownloadRequest.decodableResponseSerializer(decoder: decoder),
            completionHandler: completionHandler
        )
    }
}
