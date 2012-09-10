DZPopupController
=================


Overview
--------
DZPopupController is a floating UI component. It is a modal, iPhone-only controller resembling a mix between `UIPopoverController` crossed with `UIAlertView`.

This component is based on [CQMFloatingController](https://github.com/cocopon/CQMFloatingController), ported from [Calqum](http://www.dotapon.sakura.ne.jp/apps/calqum2/index_en.html), a customizable calculator for iPhone.


Screenshots
-----------
![Screenshot0](http://dotapon.sakura.ne.jp/github/CQMFloatingController/screenshots/0.png)
![Screenshot1](http://dotapon.sakura.ne.jp/github/CQMFloatingController/screenshots/1.png)


How to Use
----------
1. Add all `.h` and `.m` to your project
2. Write code as below:

```Objective-C
// Import a required class
#import "DZPopupController.h"

- (void)show {
    SomeViewController *viewController = [SomeViewController new];
    DZPopupController *popupController = [[DZPopupController alloc] initWithContentViewController: viewController];
    popupController.frameColor = [UIColor orangeColor];
    [popupController present];
}
```


License
-------

Copyright (c) 2012 Zachary Waldowski <zwaldowski@gmail.com>, cocopon <cocopon@me.com>, and Kent Nguyen <nguyen.dmz@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

All of the code included in BlocksKit is licensed either under BSD or MIT, or is otherwise in the public domain. You can use BlocksKit in any project, public or private, with or without attribution.


