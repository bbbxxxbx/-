# 模仿支付宝首页
* 效果一：主功能区在屏幕下方
* 效果二：主功能区在屏幕上方（与支付宝一致）

## 页面组成
### 效果一
* 整个页面主要由三个view构成：
 	1. tableView：整个页面的基础
 	2. movedView：副功能区域，位于屏幕上方
 	3. fixedView：主功能区域，位于屏幕下方

* tableView
	* headerView由一个透明的、高度与movedView一致的view构成。在headerView上还添加了一个refreshView用于展示刷新效果
	* footerView由一个透明的、高度是fixedView一半的view构成。主要用来防止fixedView遮挡了tableView的内容
	* 通过设置scrollIndicatorInsets来修改滚动条的位置

* movedView
	* 添加在tableView上
	* 高度与tableView的headerView一致，刚好将headerView上的refreshView遮挡住

* fixedView
	* 添加在控制器页面上
	* 页面上有一大一小两组图标，通过调节两组按钮的alpha值进行显示

### 效果二  
页面组成基本与效果一一致，只是各个view的大小和位置有所差异

## 交互效果
效果一和效果二的交互效果类似，因此以效果一为例。主要交互效果在tableView的代理方法`- (void)scrollViewDidScroll:(UIScrollView *)scrollView; `中实现

### `scrollView.contentOffset.y>=0`
* movedView要随着tableView一起滑动。由于movedView是添加在tableView上的，因此只要保持movedView的frame不变即可实现：
```
_movedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```

* fixedView的高度、位置与tableView的滑动位置相关
	* 当`tableViewoffsetY <= (fixedNormalHeight-fixedSmallHeight)`时，fixedView的高度不断减小，位置也不断改变，具体实现如下：
```
CGFloat tableViewoffsetY = scrollView.contentOffset.y ;
CGRect frame = _fixedView.frame ;
CGFloat height = fixedNormalHeight - tableViewoffsetY ;
frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-height, [UIScreen mainScreen].bounds.size.width, height) ;
_fixedView.frame = frame ;
``` 
	
	* 当`scrollView.contentOffset.y>(fixedNormalHeight-fixedSmallHeight)`时，fixedView的大小和位置保持不变：
```
 _fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-fixedSmallHeight, [UIScreen mainScreen].bounds.size.width, fixedSmallHeight) ;
```

* 当fixedView的高度不断减小时，大图标的alpha值逐渐减小，小图标的alpha值逐渐增大，并且小图标的frame要不断改变，使其相对位置固定：
```
CGFloat bigAlpha = tableViewoffsetY<(0.25*fixedNormalHeight)?(1.0-tableViewoffsetY/(0.25*fixedNormalHeight)):0.0 ;
CGFloat smallAlpha = tableViewoffsetY>(0.2*fixedNormalHeight)?(tableViewoffsetY-0.2*fixedNormalHeight)/(fixedNormalHeight-fixedSmallHeight-0.2*fixedNormalHeight):0.0 ;
[self adjustItems:_bigItems alpha:bigAlpha] ;
[self adjustItems:_smallItems alpha:smallAlpha] ;           
//滑动过程中保证小图标位置不变
[_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
		CGRect smallFrame = item.frame ;
		smallFrame.origin.y = 15 + fixedSmallHeight - tableViewoffsetY ;
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

### `scrollView.contentOffset.y<0`
* movedView在屏幕上的位置保持不变。滑动时，虽然tableView的frame.origin.y不会变化，但是tableView的bounds.origin.y会变化，所以tableView上所有子页面相对于tableView父页面的位置就会发生变化。因此为了使movedView固定在屏幕上，需要不断改变movedView的frame.origin.y：

```
_movedView.frame = CGRectMake(0, tableViewoffsetY, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```
* fixedView的高度和位置保持不变，大图标的alpha值为0，小图标的alpha值为1：

```
_fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tabBarHeight - fixedNormalHeight, [UIScreen mainScreen].bounds.size.width, fixedNormalHeight) ;
[self adjustItems:_bigItems alpha:1.0] ;
[self adjustItems:_smallItems alpha:0.0] ;
```

### 刷新 
* 当`scrollView.contentOffset.y>=0`时，刷新控件恰好被movedView遮挡住，不会显示
* 当`scrollView.contentOffset.y<0`时，movedView固定，刷新控件会显示出来。而当松开手指时就会进行刷新请求。请求的同时会使tableView的contentOffset保持在某一固定值，直到请求结束再恢复：

```
if(tableViewoffsetY<-60 && [scrollView isDecelerating]) {
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
为了在滑动结束后使主功能区要么显示大图标，要么小图标，需要在以下代理方法中进行处理：
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



