```swift
public func resetViews() {
  let windows = UIApplication.sharedApplication().windows as [UIWindow]
  for window in windows {
    let subviews = window.subviews as [UIView]
    for v in subviews {
      v.removeFromSuperview()
      window.addSubview(v)
    }
  }
}
```
