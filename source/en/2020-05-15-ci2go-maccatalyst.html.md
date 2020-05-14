---
title: Released CI2Go for macOS
description: I've published CI2Go the CircleCI client for macOS by porting existing iOS app using Mac Catalyst.
date: 2020-05-15 00:00
public: true
tags: ci2go, ios, macos, release, maccatalyst, circleci, ci
alternate: true
ogp:
  og:
    image:
      '': 2020-05-15-ci2go-maccatalyst/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2020-05-15-ci2go-maccatalyst/main.jpg)

I've published [CI2Go] the CircleCI client for macOS by porting existing iOS app using [Mac Catalyst].

Both iOS and macOS versions are available on App Store in same URL.

[![](images/appstore.svg)][AppStore]

READMORE

## Dark Theme

![](2020-05-15-ci2go-maccatalyst/dark-and-light.jpg)

With this release, I've also updated the iOS app to support [Dark Mode] and dropped Color Scheme feature.

## iPad Keyboard Shortcuts

![](2020-05-15-ci2go-maccatalyst/shortcuts.png)

iPad Keyboard shortcuts are supported from this update.

## WIP: Workflows

CircleCI [Workflows] are not yet completely supported but already in future milestones.

## Under The Hood

![](2020-05-15-ci2go-maccatalyst/workflow.png)

Of course, I've setup Mac Catalyst app Continuously Delivery as well as iOS version and anyone can refer this on its [GitHub repository].

Also, I've migrated package management from [Carthage] to [Swift Package Manager].

Hope this could help other developers to try building the Mac Catalyst app on CircleCI like me.

This has some workarounds like the follows.

- Swift Package build fails on macOS platform if containing Build Dependencies
    - Like: `multiple configured targets of 'KeychainAccess' are being created for macOS`
    - Duplicated build target and removed them.
    - ref: [Swift PM app in Xcode 11 (beta 5) gets four “My Mac” platform options]
- [fastlane match] can not create Provisioning Profile for Mac Catalyst.
    - Added `.provisioningprofile` files to version control and set `skip_provisioning_profiles` to `true`.

        ```rb
        match(
          type: 'development',
          app_identifier: %w(com.ci2go.ios.Circle),
          skip_provisioning_profiles: true,
          platform: 'macos'
        )
        ```

- [fastlane deliver] rejects iOS app binary with `reject_if_possible` even if `platform` is set to `osx`.
    - Set this to `false` in Mac platform settings for now.
- [fastlane deliver] fails submitting Mac app for review.
    - [Spaceship] fails handling App Store connect API.
    - ref: [tunes_client.rb]
    - `rescue` d the exception.

        ```rb
        rescue NoMethodError => e
          puts e
          raise e unless e.message == %q(undefined method `fetch' for nil:NilClass)
          puts "... Caught error, but omitting"
        end
        ```

[CI2Go]: https://ci2go.app
[Mac Catalyst]: https://developer.apple.com/mac-catalyst/
[Dark Mode]: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/dark-mode/
[Workflows]: https://circleci.com/docs/2.0/workflows/
[AppStore]: https://itunes.apple.com/app/id940028427?mt=8
[GitHub repository]: https://github.com/ngs/ci2go
[Swift Package Manager]:https://swift.org/package-manager/
[Carthage]: https://github.com/Carthage/Carthage
[fastlane match]: https://docs.fastlane.tools/actions/match/
[fastlane deliver]: https://docs.fastlane.tools/actions/deliver/
[Swift PM app in Xcode 11 (beta 5) gets four “My Mac” platform options]: https://forums.swift.org/t/swift-pm-app-in-xcode-11-beta-5-gets-four-my-mac-platform-options/27521
[tunes_client.rb]: https://github.com/fastlane/fastlane/blob/feb8cc09c9976f7f460203cf9486fd28d31f6955/spaceship/lib/spaceship/tunes/tunes_client.rb#L1138
[Spaceship]: https://github.com/fastlane/fastlane/tree/master/spaceship
