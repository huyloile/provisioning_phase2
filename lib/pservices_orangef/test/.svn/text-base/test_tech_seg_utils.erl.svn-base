%%%% This module contains svc_util_of tests and utilities for various tests.

-module(test_tech_seg_utils).

-export([run/0, online/0]).

-include("../../ptester/include/ptester.hrl").
-include("../include/ftmtlv.hrl").
-include("../../pfront_orangef/include/tlv.hrl").
-include("sachem.hrl").
-include("../../pserver/include/pserver.hrl").
-include("../../pfront_orangef/test/ocfrdp/ocfrdp_fake.hrl").
-define(P_MOBI,1).
-define(NOT_SPLITTED, ".*[^>]\$").
-define(PATH, "lib/pfront_orangef/test/webservices/postpaid_cmo/").

run() ->
    ok.

online() ->
    put(failed, false),
    tech_seg_utils(),
    case get(failed) of
	false -> ok;
	_     -> halt(1)
    end.

tech_seg_utils() ->
    BaseUid = 900000000,
    Prof = #profile{uid = BaseUid},
    ProfDefault = #profile{},
    compare(svc_util_of:get_tech_seg_int_profile(ProfDefault),undefined,?LINE),
    ProfSeg_123 = svc_util_of:set_tech_seg_int_profile(Prof, 123),
    compare(svc_util_of:get_tech_seg_int_profile(ProfSeg_123), 123, ?LINE),
    ProfSeg_1 = svc_util_of:set_tech_seg_int_profile(Prof, 1),
    delete_ofe_by_uid(BaseUid),
    rpc(svc_util_of, insert_extra_profile, [ProfSeg_1]),
    compare(rpc(svc_util_of, query_tech_seg_by_uid, [BaseUid]), 1, ?LINE),
    ProfSeg_2 = svc_util_of:set_tech_seg_int_profile(Prof, 2),
    rpc(svc_util_of, update_extra_profile, [ProfSeg_2]),
    compare(rpc(svc_util_of, query_tech_seg_by_uid, [BaseUid]), 2, ?LINE),
    Session = #session{prof = Prof},
    SessionSeg_2 = #session{prof = ProfSeg_2},
    compare(rpc(svc_util_of, update_tech_seg_int_if_needed, [Session]),
	    SessionSeg_2, ?LINE),
    compare(rpc(svc_util_of, update_tech_seg_int_if_needed, [Session]),
	    SessionSeg_2, ?LINE),
    compare(rpc(svc_util_of, redir_2g, [SessionSeg_2, "yes", "no"]),
	    {redirect, SessionSeg_2, "yes"}, ?LINE),
    compare(rpc(svc_util_of, redir_3g, [SessionSeg_2, "yes", "no"]),
	    {redirect, SessionSeg_2, "no"}, ?LINE),
    delete_ofe_by_uid(BaseUid).

compare(Gotten, Expected, Line) ->
    case Gotten == Expected of
	true ->
	    ok;
	false ->
	    put(failed, true)
    end.

rpc(Mod, Fun, Args) ->
    test_util_of:rpc(Mod, Fun, Args).


%% +type delete_ofe_by_uid(uid()) -> ok.
delete_ofe_by_uid(Uid) ->
    Cmd = io_lib:format(
	    "mysql -u possum -ppossum mobi -Bse "
	    "\"DELETE FROM users_orangef_extra WHERE uid = ~p\"", [Uid]),
    os:cmd(Cmd),
    ok.

