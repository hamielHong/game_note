-ifndef(__DEFINE_H__).
-define(__DEFINE_H__, 0).


-define(PROC_MARK, '_proc_mark').       %% 关键进程字典key，方便p(Pid)|process_info(Pid)

-define(DEF_DAY_SECOND, 86400).         %% 一天秒数

%% ERROR 打印
-define(LOG_ERROR(Format), log:error(Format)).
-define(LOG_ERROR(Format, Args), log:error("~w | line ~w" ++ Format, [?MODULE, ?LINE | Args])).

-endif.