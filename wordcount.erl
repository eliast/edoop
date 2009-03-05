#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable
-mode(compile).

map(_Key, Value, Collector) ->
  Tokens = [string:strip(Token) || Token <- string:tokens(Value, " \n")],
  [Collector({Token, 1}) || Token <- Tokens, length(Token) > 0].
  
reduce(Key, Values, Collector) ->
  Collector({Key, lists:sum(Values)}).
  
main([String]) ->
  edoop:run(String, fun map/3, fun reduce/3).