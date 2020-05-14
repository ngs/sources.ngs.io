---
title: CI2Go for macOS
description: I've published CI2Go the CircleCI client for macOS by porting existing iOS app using Mac Catalyst.
date: 2020-05-15 00:00
public: true
tags: ci2go, ios, macos, release, maccatalyst, circleci, ci
alternate: true
ogp:
  og:
    image:
      "": 2020-05-15-ci2go-maccatalyst/main.jpg
      type: image/jpeg
      width: 992
      height: 525
---

![](2020-05-15-ci2go-maccatalyst/main.jpg)

I've published [CI2Go] the CircleCI client for macOS by porting existing iOS app using [Mac Catalyst].

Both iOS and macOS versions are available on App Store in same URL.

[![](images/appstore.svg)][appstore]

Product website: [ci2go.app]

READMORE

New version for both iOS and macOS includes the following new features.

## Dark Mode

![](2020-05-15-ci2go-maccatalyst/dark-and-light.jpg)

Changed color theme to support [Dark Mode].

Color Scheme feature is no longer available.

## iPad Keyboard Shortcuts

![](2020-05-15-ci2go-maccatalyst/shortcuts.png)

iPad Keyboard shortcuts are supported from this update.

You can use <kbd>&#x2318; \[</kbd> to back navigation, <kbd>&#x2318; R</kbd> to reload and <kbd>&#8997; &#8679;　&#x2318; L</kbd> to logout.

## WIP: Workflows

CircleCI [Workflows] are not yet completely supported but already in future milestones.

## Under The Hood

![](2020-05-15-ci2go-maccatalyst/workflow.png)

Of course, I've setup Mac Catalyst app Continuous Delivery as well as iOS version.

Also, I've migrated package management from [Carthage] to [Swift Package Manager].

These are managed in public [GitHub repository] so anyone can refer.

Hope this could help other developers to try building the Mac Catalyst app on CircleCI like me.

I did some workarounds like the follows.

- Swift Package build fails on macOS platform if containing Build Dependencies
  - Like: `multiple configured targets of 'KeychainAccess' are being created for macOS`
  - Duplicated build target and removed them.
  - ref: [Swift PM app in Xcode 11 (beta 5) gets four “My Mac” platform options]
- [fastlane match] can not create Provisioning Profile for Mac Catalyst.

  - Creates for Mac when providing `platform: 'macos'`
  - Set `skip_provisioning_profiles` to `true`, added `.provisioningprofile` files to version control and copy them to `~/Library/MobileDevice/Provisioning Profiles/` on CI build step.

    ```rb
    match(
      type: 'development',
      app_identifier: %w(com.ci2go.ios.Circle),
      skip_provisioning_profiles: true,
      platform: 'macos'
    )
    ```

- [fastlane deliver] rejects iOS app binary with `reject_if_possible: true` even if `platform` is set to `osx`.
  - Set `reject_if_possible` to `false` in Mac platform settings and reject manually if I need to select new build for now.
- [fastlane deliver] fails submitting Mac app for review.

  - [Spaceship] fails handling App Store Connect API response.
  - ref: [tunes_client.rb]
  - `rescue` d the exception.

    ```rb
    rescue NoMethodError => e
      puts e
      raise e unless e.message == %q(undefined method `fetch' for nil:NilClass)
      puts "... Caught error, but omitting"
    end
    ```

## Become a sponsor

I've publish my sponsors page on [GitHub Sponsors]. Please support me polishing CI2Go if you'd like 🙇‍♂️

[ci2go]: https://ci2go.app
[mac catalyst]: https://developer.apple.com/mac-catalyst/
[dark mode]: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/dark-mode/
[workflows]: https://circleci.com/docs/2.0/workflows/
[appstore]: https://itunes.apple.com/app/id940028427?mt=8
[github repository]: https://github.com/ngs/ci2go
[swift package manager]: https://swift.org/package-manager/
[carthage]: https://github.com/Carthage/Carthage
[fastlane match]: https://docs.fastlane.tools/actions/match/
[fastlane deliver]: https://docs.fastlane.tools/actions/deliver/
[swift pm app in xcode 11 (beta 5) gets four “my mac” platform options]: https://forums.swift.org/t/swift-pm-app-in-xcode-11-beta-5-gets-four-my-mac-platform-options/27521
[tunes_client.rb]: https://github.com/fastlane/fastlane/blob/feb8cc09c9976f7f460203cf9486fd28d31f6955/spaceship/lib/spaceship/tunes/tunes_client.rb#L1138
[spaceship]: https://github.com/fastlane/fastlane/tree/master/spaceship
[ci2go.app]: https://ci2go.app
[github sponsors]: https://github.com/sponsors/ngs
