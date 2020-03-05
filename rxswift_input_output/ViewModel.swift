//
//  ViewModel.swift
//  rxswift_input_output
//
//  Created by HankTseng on 2020/3/5.
//  Copyright © 2020 hyersesign. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ViewModel {
    // 輸入轉化輸出，這裡是真正的業務邏輯代碼了
    var grout: [ViewController.CellSectionModel] = []
    func transform(input: Input) -> Output {
        let rightBtnAction = input.rightBtnAction
            .flatMapLatest { _ -> Driver<String> in
                return self.rightBtnAction()
                    .asDriver(onErrorJustReturn: "error happen")
        }

        let loading = input.rightBtnAction
            .flatMapLatest { _ -> Driver<Bool> in
                return self.isLoading()
                    .asDriver(onErrorJustReturn: true)
        }

        let dataSource = input.rightBtnAction
            .flatMapLatest { (indexPath) -> Driver<[ViewController.CellSectionModel]> in
                return self.getGrountSingleAsDriver()
        }
        return Output(rightBtnAction: rightBtnAction, loading: loading, dataSource: dataSource)
    }

    func getGrout() -> [ViewController.CellSectionModel] {
        grout.append(ViewController.CellSectionModel(items: [ViewController.CellSectionModel.Item(name: "indexPath.row")]))
        return grout
    }

    func getGrountSingle() -> Single<[ViewController.CellSectionModel]> {
        return Single.just(getGrout())
    }

    func getGrountSingleAsDriver() -> Driver<[ViewController.CellSectionModel]> {
        return getGrountSingle().asDriver(onErrorJustReturn: [ViewController.CellSectionModel(items: [ViewController.CellSectionModel.Item(name: "error happennn")])])
    }


    private func rightBtnAction() -> Single<String> {
        return Single.just("some content")
    }

    private func isLoading() -> Single<Bool> {
        return Single.just(true)
    }

}

extension ViewModel {
    // 輸入，類型是Driver，因為跟UI控件有關
    struct Input {
        let viewDidAppear: Driver<Void>
        let rightBtnAction: Driver<Void>
        let cellTitleLabelTap: Driver<IndexPath>
    }
    // 輸出，類型也是Driver
    struct Output {
        let rightBtnAction: Driver<String>
        let loading: Driver<Bool>
        let dataSource: Driver<[ViewController.CellSectionModel]>

    }
}
