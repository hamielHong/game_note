%%-------------------------------------
%% @doc 玩家属性模块
%% 测试使用定时间间隔判断脏属性
%% 的属性同步方式
%%-------------------------------------

-module(attr).

-export([
    bit_s/1    
    ,bit_n/1
    ,dirty/1
    ,dirty/2
    ,loc/1
]).

-export([
    test_bit_n/0    
    ,test_dirty/0
    ,test_dirty/1
    ,test_loc/1
    ,test_loc/2
]).


%% 查看一个数的二进制表示
bit_s(Bit) ->
    integer_to_list(Bit, 2).

%% 获得二进制低第N位为1
bit_n(N) ->
    1 bsl (N-1).

%% 将二进制某位置脏
dirty(N) -> dirty(0, N).
dirty(DirtyBit, N) ->
    DirtyBit bor bit_n(N).

%% 获得二进制所有1的低位位置
loc(DirtyBit) -> loc(DirtyBit, 1, []).
loc(0, _, LocList) -> LocList;
loc(DirtyBit, Index, LocList) ->
    LocList0 = case DirtyBit band 1 of
        0 -> LocList;
        _ -> [Index | LocList]
    end,
    loc(DirtyBit bsr 1, Index + 1, LocList0).


%% 测试循环十万次，每次转1到64
%% 耗时156ms
test_bit_n() ->
    test_bit_n(100000, 64, 0).
test_bit_n(0, 0, BitN) -> BitN;
test_bit_n(I, 0, BitN) -> test_bit_n(I-1, 64, BitN);
test_bit_n(I, J, _BitN) ->
    test_bit_n(I, J-1, bit_n(J)).

%% 测试循环十万次，每次将64位置脏
%% 耗时360ms
test_dirty() -> test_dirty(100000).
test_dirty(I) -> test_dirty(I, 64).
test_dirty(I, J) -> test_dirty(I, J, 0).
test_dirty(0, 0, DirtyBit) -> 
    DirtyBit;
test_dirty(I, 0, DirtyBit) ->
    test_dirty(I-1, 64, DirtyBit);
test_dirty(I, J, DirtyBit) ->
    test_dirty(I, J-1, dirty(DirtyBit, J)).

%% 测试循环十万次，找出所有置脏的位置
%% 耗时156ms
test_loc(DirtyBit) -> test_loc(DirtyBit, 100000).
test_loc(DirtyBit, N) -> test_loc(DirtyBit, N, []).
test_loc(_DirtyBit, 0, LocList) -> LocList;
test_loc(DirtyBit, N, _LocList) -> 
    test_loc(DirtyBit, N-1, loc(DirtyBit)).