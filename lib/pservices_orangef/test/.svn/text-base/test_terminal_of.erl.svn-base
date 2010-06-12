-module(test_terminal_of).
-compile(export_all).

run() ->
    test_tac().

online() ->
    [].

test_tac() ->
    lists:foldl(
      fun({Imei, Tac}, Count) ->
	      {Count, Tac} = {Count, terminal_of:tac(Imei)},
	      Count + 1
      end,
      1,
      [{"352288XXXXXXX1", "352288"},
       {"35303000XXXXX1", "35303000"},
       {"12345678912345", "123456"},
       {"",                default},
       {null,              default},
       {undefined,         default},
       {{na, anonymous},   default},
       {{na, null_in_db},  default}]).
