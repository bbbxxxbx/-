# 模仿支付宝首页
* 效果一：主功能区在屏幕下方
* 效果二：主功能区在屏幕上方（与支付宝一致）

## 页面组成
### 效果一
* 整个页面主要由三个view构成：
 	1. tableView：整个页面的基础
 	2. movedView：副功能区域
 	3. fixedView：主功能区域

* tableView
	* 它的headerView由一个透明的、高度与movedView一致的view构成。在headerView上还添加了一个refreshView用于展示刷新效果
	* 它的footerView由一个透明的、高度是fixedView一半的view构成。主要用来防止fixedView遮挡了tableView的内容
	* 通过设置scrollIndicatorInsets来修改滚动条的位置

* movedView
	* 添加在tableView上，能与tableView的滑动进行联动
	* 由于高度与tableView的headerView一致，因此刚好将headerView上的refreshView遮挡住

* fixedView
	* 添加在控制器页面上
	* 位置相对固定，高度随tableView的滑动而改变
	* 该页面上有一大一小两组图标，通过调节两组按钮的alpha值来进行显示

### 效果二  
页面组成基本与效果一一致，只是各个view的大小和位置有所差异

## 交互效果
效果一和效果二的交互效果类似，因此以效果一为例。主要交互效果在代理方法`- (void)scrollViewDidScroll:(UIScrollView *)scrollView; `中实现

### 滑动的contentOffset.y不小于0
* movedView要随着tableView一起滑动。由于movedView是添加在tableView上的，因此保持movedView的frame不变即可：
```
_movedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```

* fixedView的高度在一定范围内要随着tableView的滑动而改变,而位置则是相对固定的
	* 当滑动的contentOffset.y不大于fixedHeight/2时，fixedView的heiht、origin.y与滑动的contentOffset.y相关：
```
CGFloat tableViewoffsetY = scrollView.contentOffset.y ;
CGRect frame = _fixedView.frame ;
CGFloat height = fixedHeight - tableViewoffsetY ;
frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-height, [UIScreen mainScreen].bounds.size.width, height) ;
_fixedView.frame = frame ;
``` 
	
	* 当滑动的contentOffset.y大于fixedHeight/2时，fixedView的frame保持不变：
```
 _fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-tabBarHeight-fixedHeight/2, [UIScreen mainScreen].bounds.size.width, fixedHeight/2) ;
```

* 当fixedView的frame不断改变时，大图标的alpha值逐渐减小，而小图标的alpha值逐渐增大，并且小图标的frame要不断改变，使其相对位置固定：
```
//大图标透明度改变的位移范围为0～25，小图标透明度改变的位移范围为20～55
CGFloat bigAlpha = tableViewoffsetY<25?(1.0-tableViewoffsetY/25.0):0.0 ;
CGFloat smallAlpha = tableViewoffsetY>20?(tableViewoffsetY-20)/35:0.0 ;
[self adjustItems:_bigItems alpha:bigAlpha] ;
[self adjustItems:_smallItems alpha:smallAlpha] ;
```
```            
//滑动过程中保证小图标位置不变
[_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
	CGRect smallFrame = item.frame ;
	smallFrame.origin.y = 15 + fixedHeight/2 - tableViewoffsetY ;
	item.frame = smallFrame ;
}] ;
```

* 当fixedView的frame固定时，大图标的alpha值为零，小图标的alpha值为1，并且小图标的frame保持不变：
```
[self adjustItems:_bigItems alpha:0.0] ;
[self adjustItems:_smallItems alpha:1.0] ;
[_smallItems enumerateObjectsUsingBlock:^(UIButton *item, NSUInteger idx, BOOL * _Nonnull stop) {
	CGRect smallFrame = item.frame ;
	smallFrame.origin.y = 15 ;
	item.frame = smallFrame ;
}] ;
```

### 滑动的contentOffset.y小于0
* movedView保持不变。滑动时，虽然tableView的frame.origin.y不会变化，但是tableView的bounds.origin.y会变化，所以tableView上所有子页面相对于tableView父页面的位置就会发生变化。因此为了使movedView固定在父页面上，需要不断改变movedView的frame.origin.y：

```
_movedView.frame = CGRectMake(0, tableViewoffsetY, [UIScreen mainScreen].bounds.size.width, movedHeight) ;
```
* fixedView保持不变，大图标的alpha值为0，小图标的alpha值为1：

```
_fixedView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tabBarHeight - fixedHeight, [UIScreen mainScreen].bounds.size.width, fixedHeight) ;
[self adjustItems:_bigItems alpha:1.0] ;
[self adjustItems:_smallItems alpha:0.0] ;
```

### 刷新 
当tableView滑动的contentOffset.y小于某个值，并且松开手指时进行刷新请求。刷新的同时使tableView的contentOffset保持在某一固定值，直到请求结束再恢复：

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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
	 if(!decelerate) {
        if(scrollView.contentOffset.y >= 0) {
            if(scrollView.contentOffset.y < fixedHeight/4) {
                [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
            }
            else if(scrollView.contentOffset.y < fixedHeight/2) {
                [scrollView setContentOffset:CGPointMake(0, fixedHeight/2) animated:YES] ;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
    if(scrollView.contentOffset.y >= 0) {
        if(scrollView.contentOffset.y < fixedHeight/4) {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES] ;
        }
        else if(scrollView.contentOffset.y < fixedHeight/2) {
            [scrollView setContentOffset:CGPointMake(0, fixedHeight/2) animated:YES] ;
        }
    }
}
```



