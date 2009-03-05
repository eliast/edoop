-module(edoop).

-export([run/3]).

run(_Args, Mapper, _Reducer) when _Args =:= "map" ->
  map(io:get_line(''), Mapper);

run(_Args, _Map, _Reducer) when _Args =:= "reduce" ->
  groupby(io:get_line(""), _Reducer).

map(eof, _Mapper) ->
  halt(0);
map({error, _Reason}, _Mapper) ->
  halt(1);
map(Line, _Mapper) ->
  _Mapper(none, Line, fun map_collector/1),
  map(io:get_line(""), _Mapper).

map_collector(Term) ->
  io:format("~p.~n", [Term]).

groupby(Line, Reducer) ->
  {Key, Value} = eval_line(Line),
  groupby(io:get_line(""), [Value], Key, Reducer).

groupby(eof, Accum, Key, Reducer) ->
  Reducer(Key, lists:reverse(Accum), fun reducer_collector/1);
groupby({error, _Reason}, _Accum, _Key, _Reducer) ->
  halt(1);
groupby(Line, Accum, Key, Reducer) ->
  {NewKey, Value} = eval_line(Line),
  if
    NewKey =/= Key ->
      Reducer(Key, lists:reverse(Accum), fun reducer_collector/1),
      groupby(io:get_line(""), [Value], NewKey, Reducer);
    true ->
      groupby(io:get_line(""), [Value | Accum], Key, Reducer)
  end.

reducer_collector(Term) when is_tuple(Term) ->
  Output = string:join(lists:map(fun thing_to_list/1, tuple_to_list(Term)), "\t"),
  io:format("~s~n", [Output]).
  
thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_list(X)    -> X.	%Assumed to be a string
  
eval_line(Line) ->
  {ok, Tokens, _}  = erl_scan:string(Line),
  {ok, [Form]} = erl_parse:parse_exprs(Tokens),
  {value, Value, _} = erl_eval:expr(Form, []),
  Value.