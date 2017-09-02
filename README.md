# 模仿支付宝首页

## 效果图

* 效果一：主功能区在屏幕下方
![](http://note.youdao.com/yws/public/resource/cabb7d1f36a181acc60f44be2f714a52/xmlnote/WEBRESOURCE37ea512c835795c6c5a3b0628b4e9647/3304)

* 效果二：主功能区在屏幕上方（与支付宝一致）
![效果二](http://note.youdao.com/yws/public/resource/cabb7d1f36a181acc60f44be2f714a52/xmlnote/WEBRESOURCE36b230c1788d34ce691d66100c193abc/3303)


## 页面组成

### 效果一
* 整个页面主要由三个view构成：
 	1. tableView：整个页面的基础（效果图中蓝色部分）
 	2. movedView：副功能区域，位于屏幕上方（效果图中红色部分）
 	3. fixedView：主功能区域，位于屏幕下方（效果图中黄色部分）

* tableView
	* tableHeaderView是由一个透明的、高度与movedView一致的view构成。并且在headerView上添加了一个refreshView用于展示刷新效果
	* tableFooterView是由一个透明的、高度是fixedView一半的view构成。主要是为了防止fixedView遮挡了tableView的内容
	* 通过设置scrollIndicatorInsets来修改滚动条的位置

* movedView
	* 添加在tableView上
	* 高度与tableHeaderView一致，刚好将refreshView遮挡住

* fixedView
	* 添加在控制器页面上
	* 页面上有一大一小两组图标，通过调节两组按钮的alpha值进行显示

### 效果二  
页面组成基本与效果一一致，只是各个view的大小和位置有所差异

## 交互效果
效果一和效果二的交互效果类似，因此以效果一为例。
主要的交互效果是在代理方法`- (void)scrollViewDidScroll:(UIScrollView *)scrollView; `中实现的

### 当`scrollView.contentOffset.y>=0`时
* movedView要随着tableView一起滑动。由于movedView是添加在tableView上的，因此只要保持movedView的frame不变即可实现：
```
_movedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```

* fixedView的高度、位置与tableView的滑动位置相关
	* 当`scrollView.contentOffset.y <= (fixedNormalHeight-fixedSmallHeight)`时，fixedView的高度不断减小，位置也不断改变，具体实现如下：
```
CGRect frame = _fixedView.frame ;
CGFloat height = fixedNormalHeight - scrollView.contentOffset.y ;
frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-height, [UIScreen mainScreen].bounds.size.width, height) ;
_fixedView.frame = frame ;
``` 
	
	* 当`scrollView.contentOffset.y>(fixedNormalHeight-fixedSmallHeight)`时，fixedView的大小和位置保持不变：
```
 _fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-fixedSmallHeight, [UIScreen mainScreen].bounds.size.width, fixedSmallHeight) ;
```

* 当fixedView的高度不断减小时，大图标的alpha值逐渐减小，小图标的alpha值逐渐增大，并且小图标的frame要不断改变，保证其在fixedView上的相对位置不变：
```
CGFloat bigAlpha = scrollView.contentOffset.y<(0.25*fixedNormalHeight)?(1.0-scrollView.contentOffset.y/(0.25*fixedNormalHeight)):0.0 ;
CGFloat smallAlpha = scrollView.contentOffset.y>(0.2*fixedNormalHeight)?(scrollView.contentOffset.y-0.2*fixedNormalHeight)/(fixedNormalHeight-fixedSmallHeight-0.2*fixedNormalHeight):0.0 ;
[self adjustItems:_bigItems alpha:bigAlpha] ;
[self adjustItems:_smallItems alpha:smallAlpha] ;           
//滑动过程中保证小图标位置不变
[_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
		CGRect smallFrame = item.frame ;
		smallFrame.origin.y = 15 + fixedSmallHeight - scrollView.contentOffset.y ;
		item.frame = smallFrame ;
}] ;
```

* 当fixedView的高度减小到固定值时，大图标的alpha值为零，小图标的alpha值为1，并且小图标的frame保持不变：
```
[self adjustItems:_bigItems alpha:0.0] ;
[self adjustItems:_smallItems alpha:1.0] ;
[_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
		CGRect smallFrame = item.frame ;
		smallFrame.origin.y = 15 ;
		item.frame = smallFrame ;
}] ;
```

### 当`scrollView.contentOffset.y<0`时
* movedView在屏幕上的位置保持不变。滑动时，虽然tableView的frame.origin.y不会变化，但是tableView的bounds.origin.y会变化，所以tableView上所有子页面相对于tableView父页面的位置就会发生变化。因此为了使movedView固定在屏幕上，需要不断改变movedView的frame.origin.y：

```
_movedView.frame = CGRectMake(0, scrollView.contentOffset.y, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```
* fixedView的高度和位置保持不变，大图标的alpha值为0，小图标的alpha值为1：

```
_fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tabBarHeight - fixedNormalHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight) ;
[self adjustItems:_bigItems alpha:1.0] ;
[self adjustItems:_smallItems alpha:0.0] ;
```

### 刷新 
* 当`scrollView.contentOffset.y>=0`时，刷新控件恰好被movedView遮挡住，不会显示出来
* 当`scrollView.contentOffset.y<0`时，movedView固定住，刷新控件就会显示出来。而当松开手指时就会进行刷新请求。请求的同时会使tableView的contentOffset保持在某一固定值，直到请求结束再恢复：

```
if(scrollView.contentOffset.y<-60 && [scrollView isDecelerating]) {
	[self requird] ;
	[self.tableView setContentOffset:CGPointMake(0, -50) animated:YES] ;
}
```

```
- (void)requird {
	//请求内容
	[self.tableView setContentOffset:CGPointZero animated:YES] ;
}
```

### 其他
* 为了在滑动结束后主功能区的图标显示正常，需要在以下代理方法中进行相应的处理：

```
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        if(scrollView.contentOffset.y >= 0) {
            if(scrollView.contentOffset.y < fixedSmallHeight*0.5) {
                [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
            }
            else if(scrollView.contentOffset.y < fixedSmallHeight) {
                [scrollView setContentOffset:CGPointMake(0, fixedSmallHeight) animated:YES] ;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y >= 0) {
        if(scrollView.contentOffset.y < fixedSmallHeight*0.5) {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
        }
        else if(scrollView.contentOffset.y < fixedSmallHeight) {
            [scrollView setContentOffset:CGPointMake(0, fixedSmallHeight) animated:YES] ;
        }
    }
}
```


# UITableViewCell删除按钮样式自定义
## 方式一
* 思路：找到UITableViewCell的删除页面，重写页面上的删除按钮样式
* 方法：
 	1. 重写UITableViewCell的`- (void)layoutSubviews;`方法，通过遍历subViews的方式找到删除按钮所在的页面UITableViewCellDeleteConfirmationView    
 	2. 通过遍历subViews的方式在UITableViewCellDeleteConfirmationView上找到删除按钮并移除
 	3. 在UITableViewCellDeleteConfirmationView上添加自定义样式的删除按钮和点击事件
 	4. 通过控制代理方法`- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;`中返回空格的个数来决定删除按钮的宽度
 	5. 需要实现代理方法`- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;`，就算没有具体内容也可以
* 优点：由于只是修改了样式，因此相关的交互效果与系统的一致
* 局限性：删除按钮的样式有一定的局限性，并且在iOS11上，UITableViewCell删除按钮的实现形式从根本上有了改变，该方法失效 

## 方式二  
* 思路：自定义UITableViewCell
* 方法：
	1. 为了尽量与系统的交互效果保持一致（即滑动删除），自定义UITableViewCell的主体控件是UIScrollView	
	2. 所有其它的控件，包括自定义的删除按钮都是添加在这个scrollView上的
	3. 为了滑动后有足够的空间显示删除按钮，将scrollView的contentSize设置为`CGSizeMake(ScreenWidth + deleteBtnWidth + margin, CellHeight)`
	4. 删除按钮的处理方式有两种：
		1. 添加在屏幕之外，固定在scrollView上，会随着scrollView的滑动而逐渐显示在屏幕上
		2. 添加在屏幕之内，被另一个页面遮盖住。遮盖它的页面固定在scrollView上，会随着scrollView的滑动逐渐移开；而它在scrollView内的位置会随着scrollView的滑动而不断改变，使其在屏幕上的位置保持不变
		3. 为了与系统效果更相近，demo选择了方式二
		
		```
		- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.x > 0) {
    _deleteBtn.frame = CGRectMake(scrollView.contentOffset.x + ScreenWidth - deleteBtnWidth - margin, 7.5, deleteBtnWidth, CellHeight - 15) ;
    }
    else {
        _deleteBtn.frame = CGRectMake(ScreenWidth - deleteBtnWidth - margin, 7.5, deleteBtnWidth, CellHeight - 15) ;
    }
}
		```

* 注意：
	1. 由于scrollView会吸收触摸事件，为了让tableViewCell能够接收到触摸事件，需要重写scrollView的相关方法：
	```
	- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}
	```	
	
	2. 在显示删除按钮的情况下点击tableViewCell需隐藏删除按钮
	```
	- (void)clickWithCompletion:(void(^)(void))completion {
    if(_scrollView.contentOffset.x > 0) {
        //滑动过程中禁止scrollView的交互，防止重复点击引起的卡顿效果
        _scrollView.userInteractionEnabled = NO ;
        [UIView animateWithDuration:0.3 animations:^{
        [_scrollView setContentOffset:CGPointZero] ;
        } completion:^(BOOL finished) {
        _scrollView.userInteractionEnabled = YES ;
        }] ;
    }
    else {
        completion () ;
    }
}
	```
	
	3. 由于UITableViewCell的重用机制，如果某一行cell左滑显示了删除按钮，在此情况下滑动tableView，那么将会在其它行出现显示删除按钮的cell。为了解决该问题，需要创建一个对象来记录每个cell删除按钮的显示情况

* 优点：删除按钮的样式能够完全自定义，不受系统的限制
* 局限性：交互效果与系统的相比有所差异


