//
//  RxSubjectsViewController.swift
//  rxswift_input_output
//
//  Created by HankTseng on 2020/3/25.
//  Copyright © 2020 hyersesign. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxSubjectsViewController: UIViewController {

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

//        demoPublishSubject()
//        demoBehaviorSubject()
//        demoReplaySubject()
        demoBehaviorRelay()

    }

    func demoPublishSubject() {
        let publishSubject = PublishSubject<String>()
        publishSubject.onNext("first element")
        publishSubject
            .subscribe{ print($0) }
            .disposed(by: disposeBag)
        publishSubject.onNext("sec element")
    }

    func demoBehaviorSubject() {
        let behaviorSubject = BehaviorSubject<String>(value: "init value")
        behaviorSubject.onNext("first element")
        behaviorSubject
            .subscribe( onNext: { print($0) })
            .disposed(by: disposeBag)
    }

    func demoReplaySubject() {
        let replaySubject = ReplaySubject<String>.create(bufferSize: 4)
        replaySubject.onNext("first element")
        replaySubject.onNext("sec element")
        replaySubject
            .skip(2)
            .subscribe{ print($0)}
            .disposed(by: disposeBag)
        replaySubject.onNext("third element")

    }

    func demoBehaviorRelay() {
        let behaviorRelay = BehaviorRelay<String>.init(value: "init value")
//        behaviorRelay.accept("first element")
//        behaviorRelay.accept("sec element")
//        behaviorRelay.accept("third element")
        behaviorRelay
//        .skip(1)
            .subscribe( onNext: { element in
                print(element)
            })
            .disposed(by: disposeBag)
//        behaviorRelay.accept("first element")
//        behaviorRelay.accept("sec element")
    }




}
