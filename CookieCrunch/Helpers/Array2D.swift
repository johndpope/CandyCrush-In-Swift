//
//  Array2D.swift
//  CookieCrunch
//
//  Created by Cecilia Humlelu on 26/11/14.
//  Copyright (c) 2014 HU. All rights reserved.
//

import Foundation


struct Array2D<T> {
    let columns:Int
    let rows:Int
    
    private var array:Array<T?>
    
    init(columns:Int,rows:Int){
        self.columns = columns
        self.rows = rows
        self.array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(column:Int,row:Int) -> T? {
        get{
            return array[row*columns+column]
        }
        set{
            array[row*columns+column] = newValue
        }
    }
    
}