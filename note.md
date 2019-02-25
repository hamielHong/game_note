小笔记
===

抽奖系统
---

* 抽奖逻辑研究下，概率是怎么计算的

Erlang
---

* 打印堆栈信息，可用于分析递归调用

> io:format("~w~n", [erlang:process_display(self(), backtrace)])

* Erlang中列表分为严格列表（proper list）和非严格列表（improper list），使用非严格列表在遍历到最后时不是空列表nil（[]），容易引发一些问题