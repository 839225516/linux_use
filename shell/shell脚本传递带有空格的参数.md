shell 脚本传递带有空格的参数

```shell
#/bin/bash

function myEcho(){
    echo "参数个数$#"
    for var in "$@"
    do
        echo "$var"
    done
}

test="hello world"
myEcho $test
myEcho "$test"
```



