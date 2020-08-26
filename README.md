# gaussian_fit
将数据分解成多个高斯函数之和, 如下图所示:

![拟合结果](https://raw.githubusercontent.com/yfor1008/gaussian_fit/master/src/拟合结果.png)

## 原理

1. 用多个高斯函数对数据进行表示, 公式如下:

$$
G(x)=\sum_{i=1}^{n}(height_i*e^{-(\frac{x-position_i}{width_i})^2})
$$

式中, $n$ 为高斯核函数个数, $height_i$ , $position_i$ , $width_i$ 分别为第 $i$ 个高斯核的参数.

2. 采用最小二乘与迭代方式求解高斯函数的参数

## 使用方法

知道高斯核个数时, 可以使用如下方法:

```matlab
gStr = gaussianFit(x,y,gNum); % x,y为数据, gNum为高斯核个数
```

不知道高斯核个数时, 可以使用如下方法, 自动进行高斯拟合, 寻找最合适的高斯核个数:

```matlab
gStr = autoGauFit(x,y,gNum); % x,y为数据
```

详见 `test.m` 文件.

## 结果可视化

```matlab
visualizationProcess(x, y, gStr, 'final'); % 最终结果
% visualizationProcess(x, y, gStr, 'process'); % 处理过程
```

处理过程可视化如下图所示:

![迭代过程](https://raw.githubusercontent.com/yfor1008/gaussian_fit/master/src/迭代过程.gif)

## 2D拟合

### 使用方法

```matlab
same = 1; % same=1, x 和 y 方向方差相同; same=0, 方差不同
gStr = gaussianFit2D(x, y, z, same);
```

### 结果展示

如下所示:

```matlab
% visualizationProcess2D(x, y, z, gStr, 'final'); % 最终结果
visualizationProcess2D(x, y, z, gStr, 'process'); % 最终结果
```

![2D迭代过程](https://raw.githubusercontent.com/yfor1008/gaussian_fit/master/src/迭代过程_2D.gif)

## 参考

1. https://terpconnect.umd.edu/~toh/spectrum/CurveFittingC.html