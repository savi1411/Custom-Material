import UIKit
import RxSwift
import RxRelay

var str = "Hello, playground"

// MARK: - Observables e Subscribers
example(of: "just, of, from") {
    // 1
    let one = 1
    let two = 2
    let three = 3
    
    // 2
    let observable = Observable<Int>.just(one)
    
    let observable2 = Observable.of(one, two, three)

    let observable3 = Observable.of([one, two, three])

    let observable4 = Observable.from([one, two, three])

}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe { event in
        print(event)
    }
    
    observable.subscribe { event in
        if let element = event.element {
        print(element)
      }
    }
    
    observable.subscribe(onNext: { element in
      print(element)
    })

}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        // 1
        onNext: { element in
            print(element)
        },
        
        // 2
        onCompleted: {
            print("Completed")
        }
    )
    
}

example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
  // 1
  let observable = Observable<Int>.range(start: 1, count: 10)
  
  observable
    .subscribe(onNext: { i in
      // 2
      let n = Double(i)
      
      let fibonacci = Int(
        ((pow(1.61803, n) - pow(0.61803, n)) /
          2.23606).rounded()
      )
      
      print(fibonacci)
  })
}

example(of: "dispose") {
    // 1
    let observable = Observable.of("A", "B", "C")
    
    // 2
    let subscription = observable.subscribe { event in
        // 3
        print(event)
    }
    subscription.dispose()
    
}

example(of: "DisposeBag") {
    // 1
    let disposeBag = DisposeBag()
    
    // 2
    Observable.of("A", "B", "C")
        .subscribe { // 3
            print($0)
        }
        .disposed(by: disposeBag) // 4
}

example(of: "create") {
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        // 1
        observer.onNext("1")
        
//        observer.onError(MyError.anError)
        
        // 2
        observer.onCompleted()
        
        // 3
        observer.onNext("?")
        
        // 4
        return Disposables.create()
    }
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
    )
    .disposed(by: disposeBag)
}

example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    // 1
    var flip = false
    
    // 2
    let factory: Observable<Int> = Observable.deferred {
        
        // 3
        flip.toggle()
        
        // 4
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
      factory.subscribe(onNext: {
        print($0, terminator: "")
      })
      .disposed(by: disposeBag)

      print()
    }

}

example(of: "Single") {
    // 1
    let disposeBag = DisposeBag()
    
    // 2
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    // 3
    func loadText(from name: String) -> Single<String> {
        // 4
        return Single.create { single in
            
            // 1
            let disposable = Disposables.create()

            // 2
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
              single(.error(FileReadError.fileNotFound))
              return disposable
            }

            // 3
            guard let data = FileManager.default.contents(atPath: path) else {
              single(.error(FileReadError.unreadable))
              return disposable
            }

            // 4
            guard let contents = String(data: data, encoding: .utf8) else {
              single(.error(FileReadError.encodingFailed))
              return disposable
            }

            // 5
            single(.success(contents))
            return disposable

        }
    }
    
    // 1
    loadText(from: "Copyright")
        // 2
        .subscribe {
            // 3
            switch $0 {
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
    
}

// MARK: - Subjects
example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    // Foi recebido e impresso pelos 2 subscribers
    subject.onNext("3")
    subscriptionOne.dispose()

    subject.onNext("4")
    
    // 1
    subject.onCompleted()

    // 2
    subject.onNext("5")

    // 3
    subscriptionTwo.dispose()

    let disposeBag = DisposeBag()

    // 4
    subject
      .subscribe {
        print("3)", $0.element ?? $0)
      }
      .disposed(by: disposeBag)

    subject.onNext("?")

}

// 1
enum MyError: Error {
  case anError
}

// 2
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
  print(label, (event.element ?? event.error) ?? event)
}

// 3
example(of: "BehaviorSubject") {
  // 4
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
    
    subject
      .subscribe {
        print(label: "1)", event: $0)
      }
      .disposed(by: disposeBag)

    subject.onNext("X")
    
    // 1
    subject.onError(MyError.anError)

    // 2
    subject
      .subscribe {
        print(label: "2)", event: $0)
      }
      .disposed(by: disposeBag)

}

example(of: "ReplaySubject") {
  // 1
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()

  // 2
  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")

  // 3
  subject
    .subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

  subject
    .subscribe {
      print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError)
    subject.dispose()

    subject
      .subscribe {
        print(label: "3)", event: $0)
      }
      .disposed(by: disposeBag)
    
}

example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock, anyone home?")
    
    relay
      .subscribe(onNext: {
        print($0)
      })
      .disposed(by: disposeBag)

    relay.accept("1")

}

example(of: "BehaviorRelay") {
    // 1
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    // 2
    relay.accept("New initial value")
    
    // 3
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    relay.accept("1")

    // 2
    relay
      .subscribe {
        print(label: "2)", event: $0)
      }
      .disposed(by: disposeBag)

    // 3
    relay.accept("2")
    
    print(relay.value)

}




