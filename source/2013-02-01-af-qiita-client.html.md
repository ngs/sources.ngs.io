---
title: AFQiitaClient の使い方
description: AFQiitaClient は Qiita API を Cocoa で操るクライアントです。
date: 2013-02-01 00:00
public: true
tags: objective-c, cocoapods, cocoa, qiita, afnetworking, hackathon
---

[AFQiitaClient](https://github.com/ngs/AFQiitaClient) は [Qiita API](http://qiita.com/docs) を Cocoa で操るクライアントです

https://github.com/ngs/AFQiitaClient

`AFQiitaClient` は `AFHTTPClient` サブクラスで、[AFNetworking](https://github.com/afnetworking/afnetworking) のソースコードと共に、プロジェクトに追加して使用します。

[CocoaPods](http://cocoapods.org/) からも追加できます。

```ruby
pod 'AFQiitaClient'
```

## 使い方

### 初期化
```objc
AFQiitaClient *client = [[AFQiitaClient alloc] init];
```

### 認証
```objc
[client authenticateWithUsername:@"ngs"
                        password:@"qwerty1234!?"
                        success:^ {
                          NSLog(@"Success");
                        }
                        failure:^(NSError *error) {
                          NSLog(@"Error: %@", error);
                        }];
```

### ページング
`AFQiitaResponse` には `firstURL`, `prevURL`, `nextURL`, `prevURL` という NSURL を返却するインスタンスメソッドがある。

```objc
[client tagsWithSuccess:^(AFQiitaResponse *response) {
                  if(response.nextURL) {
                    [client getURL:response.nextURL
                           success:^(AFQiitaResponse *response) { ... }
                           failure:^(NSError *error) { ... }];
                  } else {
                    NSLog(@"No more tags");
                  }
                }
                failure:^(NSError *error) {
                  NSLog(@"Error: %@", error);
                }];
```


### 残りリクエスト可能数とRate Limit取得
```objc
[client rateLimitWithSuccess:^(NSInteger remaining, NSInteger limit){
                        NSLog(@"Success: Limted to %d, %d remaining", limit, remaining);
                      }
                      failure:^(NSError *error) {
                        NSLog(@"Error: %@", error);
                      }];
```

### リクエストユーザーの情報取得
```objc
[client currentUserWithSuccess:^(AFQiitaResponse *response) {
                         AFQiitaUser *me = [response first];
                         NSLog(@"Success: Hello, my name is %@", me.name);
                       }
                       failure:^(NSError *error) {
                         NSLog(@"Error: %@", error);
                       }];
```

### 特定ユーザーの情報取得
```objc
[client userWithUsername:@"yaotti@github"
                 success:^(AFQiitaResponse *response) {
                   AFQiitaUser *user = [response first];
                   NSLog(@"Success: %@ has %d followers", user.name, user.followers);
                 }
                 failure:^(NSError *error) {
                   NSLog(@"Error: %@", error);
                 }];
```

### 特定ユーザーの投稿取得
```objc
[client itemsWithUsername:@"yaotti@github"
                  success:^(AFQiitaResponse *response) {
                    AFQiitaItem *item = nil;
                    while(item = response.next)
                      NSLog(@"Post: %@", item.title);
                  }
                  failure:^(NSError *error) {
                    NSLog(@"Error: %@", error);
                  }];
```

### 特定ユーザーのストックした投稿取得
```objc
[client stockedItemsWithUsername:@"yaotti@github"
                         success:^(AFQiitaResponse *response) {
                           AFQiitaItem *item = nil;
                           while(item = response.next)
                             NSLog(@"Post: %@", item.title);
                         }
                         failure:^(NSError *error) {
                           NSLog(@"Error: %@", error);
                         }];
```

### 特定タグの投稿取得
```objc
[client itemsWithTag:@"Rails"
             success:^(AFQiitaResponse *response) {
               AFQiitaItem *item = nil;
               while(item = response.next)
                 NSLog(@"Post: %@", item.title);
             }
             failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
             }];
```

### タグ一覧取得
```objc
[client tagsWithSuccess:^(AFQiitaResponse *response) {
                  AFQiitaTag *tag = nil;
                  while(tag = response.next)
                    NSLog(@"Tag: %@", tag.name);
                }
                failure:^(NSError *error) {
                  NSLog(@"Error: %@", error);
                }];
```

### 検索結果取得
```objc
[client itemsWithSearchString:@"Hackathon"
                      stocked:NO
                      success:^(AFQiitaResponse *response) {
                        AFQiitaItem *item = nil;
                        while(item = response.next)
                          NSLog(@"Post: %@", item.title);
                      }
                      failure:^(NSError *error) {
                        NSLog(@"Error: %@", error);
                      }];
```

### 新着投稿の取得
```objc
[client recentItemsWithSuccess:^(AFQiitaResponse *response) {
                         AFQiitaItem *item = nil;
                         while(item = response.next)
                           NSLog(@"Post: %@", item.title);
                       }
                       failure:^(NSError *error) {
                         NSLog(@"Error: %@", error);
                       }];
```

### 自分のストックした投稿の取得
```objc
[client stockedItemsWithSuccess:^(AFQiitaResponse *response) {
                          AFQiitaItem *item = nil;
                          while(item = response.next)
                            NSLog(@"Post: %@", item.title);
                        }
                        failure:^(NSError *error) {
                          NSLog(@"Error: %@", error);
                        }];
```


### 投稿の実行
```objc
AFQiitaItem *item = [[AFQiitaItem alloc]
                      initWithTitle:@"テスト！"
                      body:@"[AFQiitaClient](http://github.com/ngs/AFQiitaClient) から投稿テスト"];

[item addTag:[AFQiitaTag tagWithName:@"iOS"
                            versions:@"5.1.1", @"6.0", nil]];

[item setTweet:YES]; // Posts URL to Twitter
[item setGist:YES];  // Share code blocks on Gist

[client createItem:item
           success:^(AFQiitaResponse *response) {
             AFQiitaItem *createdItem = [response first];
             NSLog(@"Success! UUID is %@", createdItem.uuid);
           }
           failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
           }];
```

### 投稿の更新
```objc
AFQiitaItem *item = ...; // Received from API

[item setTitle:@"テスト！(追記アリ)"];
[item setBody:@"[AFQiitaClient](http://github.com/ngs/AFQiitaClient) から投稿テスト\n\n##追記 (2012/10/13)\n\n* 非公開にしてみた"];

[item removeTag:[item.tags objectAtIndex:2]];
[item addTag:[AFQiitaTag tagWithName:@"Rails"]];

[item publicize]; // 限定公開のものを public に変更のみ可能

[client updateItem:item
           success:^(AFQiitaResponse *response) {
             AFQiitaItem *updatedItem = [response first];
             NSLog(@"Success! Updated at %@", updatedItem.updatedAt);
           }
           failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
           }];
```

### 投稿の削除
```objc
[client deleteItem:item // Alias for deleteItemWithUUID:(NSString *)uuid
           success:^(AFQiitaResponse *response) {
             NSLog(@"Successfully deleted");
           }
           failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
           }];
```

### 特定の投稿取得
```objc
[client itemWithUUID:@"1a43e55e7209c8f3c565"
             success:^ {
             AFQiitaItem *item = [response first];
               NSLog(@"Success: Title is %@, posted by %@ at %@",
                 item.title, item.user.name, item.createdAt);
             }
             failure:^(NSError *error) {
               NSLog(@"Error: %@", error);
             }];
```

### 投稿のストック
```objc
[client stockItem:item // Alias for stockItemWithUUID:(NSString *)uuid
          success:^ {
            NSLog(@"Successfully stocked");
          }
          failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
          }];
```

### 投稿のストック解除
```objc
[client unstockItem:item // Alias for unstockItemWithUUID:(NSString *)uuid
            success:^ {
              NSLog(@"Successfully unstocked");
            }
            failure:^(NSError *error) {
              NSLog(@"Error: %@", error);
            }];
```

----

## 連絡先

[Atsushi Nagase](http://ngs.io/about)

[@ngs](https://twitter.com/ngs)

## ライセンス
AFQiitaClient は MIT ライセンスで配布しています。 詳しくは LICENSE ファイルをご覧ください。

