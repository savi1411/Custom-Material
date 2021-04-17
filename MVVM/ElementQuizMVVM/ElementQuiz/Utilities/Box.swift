//
//  Box.swift
//  ElementQuiz
//
//  Created by Carlos Alberto Savi on 26/03/21.
//  Copyright © 2021 Apple Inc. All rights reserved.
//

import Foundation

final class Box<T> {
  //1
  typealias Listener = (T) -> Void
  var listener: Listener?
  //2
  var value: T {
    didSet {
      listener?(value)
    }
  }
  //3
  init(_ value: T) {
    self.value = value
  }
  //4
  func bind(listener: Listener?) {
    self.listener = listener
    listener?(value)
  }
}
