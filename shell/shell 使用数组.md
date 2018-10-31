### shell 数组

shell 数组有两种数据类型：

    数值类型
    字符类型

定义：用一对括号表示数组，数组中元素之间用"空格"来隔开；字符类型数组的元素用双引号或单引号包含，同样用空格来隔开。元素下标从0开始。
```shell
arr_number=(1 2 3 4 5)
arr_string=("hello" "world")


#数组个数 
length=${arr_number[*]}

#获取数组单个元素的长度
lengthN=${arr_string[1]}

#遍历数组
for key in ${arr_number[@]}
do 
    echo $key
done
```




