//
//  CellProtocols.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import Foundation

//protocol intended for the viewmodel structs
//used for configuring cells
public protocol CellConfigurator {
    //id used for dequeueCell
    var cellIdentifier: String { get }
}

//protocol used by tableview cells to update
//the UI of the cell based upon the viewmodel
//data contained in the configurator
public protocol CellConfigurable {
    
    func configure(_ configurator: CellConfigurator)
}
