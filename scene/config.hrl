-record(cfg_scene, {
    id = 0              %% id
    ,name = <<>>        %% 名称
    ,type = 0           %% 类型，见 scene.hrl SCENE_TYPE_* 定义
    ,sub_type = 0       %% 子类型
    ,clusters = 0       %% 是否跨服场景，0本服独有 1跨服独有 2本服跨服都有
    ,broadcast = 0      %% 是否全场景广播，0否 1是
    ,person = 0         %% 线路可容纳人数上限
    ,team = 0           %% 能否组队，0否 1是
    ,follow = 0         %% 能否跟随，0否 1是
    ,map_id = 0         %% 地图可行走区域id
    ,resource_id = 0    %% 资源id
    ,width = 0          %% 宽度
    ,height = 0         %% 高度
    ,lv = 0             %% 进入的 玩家等级 限制
    ,pk = []            %% 进入的 pk模式 限制
    ,use_pk_mode = 0    %% 场景是否锁定 普通pk模式，0否 1是 为0时场景内战斗为阵营模式
    ,mon_vs_mon = 0     %% 是否允许怪打怪，0否 1是
    ,npc = []           %% npc [{NpcId, X, Y}, ...]
    ,mon = []           %% 怪物 [{MonTypeId, X, H, Y, Section, 朝向, 寻路点列表, 召唤时间, KVList}, ...]
                        %% 其中 Section:属于场景第几波怪，召唤时间:毫秒
    ,obj = []           %% 物件
    ,revive = []        %% 复活配置 [#cfg_revive{}, ...]
                        %% 根据 复活类型 不同，如复活点复活 | 原地复活 | 阵营战复活，需要多个复活配置
                        %% 其中阵营战复活，根据阵营不同也可能需要多个复活配置
    ,elem = []          %% 地图传送阵 [{传送阵索引, 场景id, 对方场景传送阵索引id, x, h, y, Face}, ...]
                        %% 区别于传送点，传送阵为场景中可见，两个传送阵互相连接，走入即可传送到对方传送阵
    ,exit_point = []    %% 传送点, [{Index, X, H, Y, Face}, ...]
                        %% 区别于传送阵，传送点为场景中不可见，作为小地图飞行等操作的目标点
    ,born_point = []    %% 出生点配置 [[Index, X, H, Y, 朝向, 随机范围], ...]
    ,forbidden = []     %% 场景禁止事件 ,见 scene.hrl SCENE_BAN_* 定义
    ,rush_type = []     %% 隐藏关卡(预留)
    ,key_value = []     %% 特殊附加数据(预留)
}).