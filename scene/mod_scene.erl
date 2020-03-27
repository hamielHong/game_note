-module(mod_scene).
-behaviour(gen_server).

%% API
-export([
    start_scene/5,      %% 创建场景进程
    start_scene/7,
    cast/2,
    stop/1
]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("define.hrl").
-include("config.hrl").
-include("scene.hrl").


start_scene(CfgScene, LineId, IsCopy, LinePid, KeepAliveTime) ->
    start_scene(CfgScene, LineId, IsCopy, LinePid, [], [], KeepAliveTime).

start_scene(CfgScene, LineId, IsCopy, LinePid, KvList, Options, KeepAliveTime) ->
    {ok, ScenePid} = start(CfgScene, LineId, IsCopy, LinePid, KvList, Options, KeepAliveTime),
    lib_scene_api:insert_scene_pid(CfgScene#cfg_scene.id, LineId, ScenePid),
    ScenePid.

start(CfgScene, LineId, IsCopy, LinePid, KvList, Options, KeepAliveTime) ->
    SpawnOpt = [{spawn_opt, [
        {min_heap_size, 51200},         %% 100kb  进程最小堆大小
        {min_bin_vheap_size, 51200},    %% 100kb  进程最小虚拟二进制堆大小
        {fullsweep_after, 100}          %% 深扫描的频率 N次gc后执行一次深度gc
    ]}],
    gen_server:start(?MODULE, [CfgScene, LineId, IsCopy, LinePid, KvList, Options, KeepAliveTime], SpawnOpt).


init([CfgScene, LineId, IsCopy, LinePid, KvList, Options, KeepAliveTime]) ->
    process_flag(trap_exit, true),
    %% 进程标记
    put(?PROC_MARK, {scene, [{id, CfgScene#cfg_scene.id}, {line, LineId}]}),

    %% 启动怪物管理进程
    mod_mon_agent:start_agent(CfgScene, LineId, self(), KvList, Options),
    %% 启动物件管理进程
    mod_scene_obj:start(CfgScene, LineId),

    case IsCopy of
        true ->     %% 房间类场景
            %% 定时关闭进程，最大不超过一天，KeepAliveTime = 0不关闭
            SleepTime = min(?DEF_DAY_SECOND, KeepAliveTime),
            SleepTime > 0 andalso erlang:send_after(SleepTime * 1000, self(), timer_force_stop);
        _ ->
            %% 如果是线路类进程，需要发送到线路控制进程上等级
            case LineId > 0 andalso is_pid(LinePid) of
                true ->
                    LinePid ! {add_line, LineId},
                    %% 定时修复 场景人数和线路管理进程记录的人数 是否一致
                    erlang:send_after(util:rand(1200, 1800) * 1000, self(), fix_line_person);
                _ ->
                    skip
            end
    end,
    
    State = #scene{
        id = CfgScene#cfg_scene.id,
        line_id = LineId,
        type = CfgScene#cfg_scene.type,
        sub_type = CfgScene#cfg_scene.sub_type,
        broadcast = CfgScene#cfg_scene.broadcast,
        multi_line = data_scene_config:is_multi_scene(CfgScene#cfg_scene.type),
        kvlist = KvList
    },
    {ok, State}.


cast(ScenePid, Event) ->
    gen_server:cast(ScenePid, Event).


stop(ScenePid) ->
    cast(ScenePid, stop),
    ok.


handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(Event, From, State) ->
    case catch do_call(Event, From, State) of
        {'EXIT', Error} ->
            ?LOG_ERROR("handle_call Event: ~W, <<<<<< Err >>>>>>: ~p", [Event, Error]),
            {reply, error, State};
        Any -> Any
    end.

handle_cast(Event, State) ->
    case catch mod_scene_cast:handle_cast(Event, State) of
        {'EXIT', Error} ->
            ?LOG_ERROR("handle_cast Event: ~W, <<<<<< Err >>>>>>: ~p", [Event, Error]),
            {noreply, State};
        Any -> Any
    end.

handle_info(Event, State) ->
    case catch do_info(Event, State) of
        {'EXIT', Error} ->
            ?LOG_ERROR("handle_info Event: ~W, <<<<<< Err >>>>>>: ~p", [Event, Error]),
            {noreply, State};
        Any -> Any
    end.

terminate(_Reason, Scene) ->
    %% 关闭怪物管理进程
    mod_mon_agent:stop_agent(Scene#scene.id, Scene#scene.line_id),

    %% 关闭物件管理进程
    mod_scene_obj:stop(Scene#scene.id, Scene#scene.line_id),

    %% 删除场景进程Pid缓存
    lib_scene_api:delete_scene_pid(Scene#scene.id, Scene#scene.line_id),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% 默认匹配
do_call(Event, _From, Scene) ->
    ?LOG_ERROR("~w:handle_call not match: ~w", [?MODULE, Event]),
    {reply, error, Scene}.

do_info(Event, Scene) ->
    ?LOG_ERROR("~w:handle_info not match: ~w", [?MODULE, Event]),
    {noreply, Scene}.