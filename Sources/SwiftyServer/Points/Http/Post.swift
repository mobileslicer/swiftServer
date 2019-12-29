//
//  File.swift
//  
//
//  Created by Muhammet Mehmet Emin Kartal on 12/21/19.
//

import Foundation



struct PostPoint<O: Decodable, R: HTTPEnviroment>: Point {
	typealias Enviroment = R

	func perform(on request: inout Enviroment) throws -> O {

		guard let data = request.httpParameters.body else {
			throw PostError.noBodyFound
		}

		return try JSONDecoder().decode(O.self, from: data)
	}

	var upstream: Never {
		fatalError()
	}

	enum PostError: Error {
		case noBodyFound
	}

	typealias Output = O

	var path: String

	public init(path: String) {
		R.Server.endPoints.add(path: path, method: "POST")
		R.Server.endPoints.add(type: "\(O.Type.self)")
		self.path = path
	}
}



struct RePostPoint<In: Point, O: Decodable>: Point where In.Enviroment: HTTPEnviroment {
	typealias Enviroment = In.Enviroment

	func perform(on request: inout Enviroment) throws -> O {

		_ = try upstream.perform(on: &request)

		return try JSONDecoder().decode(O.self, from: request.httpParameters.body ?? Data())
	}

	var upstream: In
	typealias Output = O
}

extension RequestEnviroment where Self: HTTPEnviroment {
	static func post<T: Decodable>(_ path: String, type: T.Type) -> PostPoint<T, Self> {
		return PostPoint(path: path)
	}
}


extension Point where Enviroment: HTTPEnviroment {
	
	func repost<T: Decodable>(type: T.Type) -> RePostPoint<Self, T> {
		return RePostPoint(upstream: self)
	}
}