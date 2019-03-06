

```shell
#!/bin/bash

Hi_string="Hello world"
var=Hi
# ${var}_string 作为变量名
res=`eval echo '$'"${var}_string"`

echo $res
```