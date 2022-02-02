//
//  NewsViewModelFactory.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 02.02.2022.
//

import Foundation
import UIKit

final class NewsViewModelFactory {
    
    private let photoService = PhotoService.instance
    
    func constructViewModels(from news: [News]) -> [NewsViewModel] {
        return news.compactMap(self.viewModel)
    }
    
    private func viewModel(from news: News) -> NewsViewModel {
        let text = news.text
        let name = news.name
        let date = news.date

        let likeCount = String(news.likesCount)
        let repostCount = String(news.repostsCount)
        let commentsCount = String(news.commentsCount)
        
        let avatarUrl = news.avatar
        let photoURL = news.photoURL
        
        let photoWidth = news.photoWidth
        let photoHeight = news.photoHeight

        return NewsViewModel(date: date,
                             text: text,
                             commentsCount: commentsCount,
                             likesCount: likeCount,
                             repostsCount: repostCount,
                             name: name,
                             avatarURL: avatarUrl,
                             photoPostURL: photoURL,
                             photoHeight: photoHeight,
                             photoWidth: photoWidth)
        
    }
}
