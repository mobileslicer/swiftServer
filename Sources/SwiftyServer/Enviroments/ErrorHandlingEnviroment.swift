//
//  File.swift
//  
//
//  Created by Muhammet Mehmet Emin Kartal on 12/22/19.
//

import Foundation

protocol ErrorHandlingEnviroment: RequestEnviroment {

	associatedtype ErrorType: Error
}