%%% 场景相关 %%%

%% 场景类型
-define(SCENE_TYPE_MAIN_CITY, 1).       %% 主城
-define(SCENE_TYPE_FIELD, 2).           %% 野外
-define(SCENE_TYPE_DUNGEON, 3).         %% 副本
-define(SCENE_TYPE_BATTLE, 4).          %% 战场
-define(SCENE_TYPE_INTERACT, 5).        %% 交互
-define(SCENE_TYPE_BOSS, 6).            %% BOSS

%% 场景子类型
-define(SCENE_SUB_TYPE_NORMAL_DUN, 300).        %% 普通副本
-define(SCENE_SUB_TYPE_NORMAL_TEAM_DUN, 301).   %% 普通组队副本

%% 场景禁止事件
-define(SCENE_BAN_PK_MODE, 1).          %% 禁止使用PK模式
-define(SCENE_BAN_MOUNT, 2).            %% 禁止上坐骑
-define(SCENE_BAN_USE_DRUG, 3).         %% 禁止使用药品
-define(SCENE_BAN_MEDITATION, 5).       %% 禁止冥想


%%% RECORD %%%

%% 场景进程 mod_scene 状态数据
-record(scene, {
    id = 0,             %% 场景id
    line_id = 0,        %% 线路id
    type = 0,           %% 类型 见 scene.hrl SCENE_TYPE_* 定义
    sub_type = 0,       %% 子类型
    broadcast = 0,      %% 是否全场景广播
    multi_line = false, %% 是否多线路(只有主城和野外才是多线路场景，有mod_line进程管理)
    kvlist = []
}).