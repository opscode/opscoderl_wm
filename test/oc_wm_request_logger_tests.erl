%% @copyright 2013 Opscode Inc.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% @author Matthew Peck <matthew@opscode.com>
-module(oc_wm_request_logger_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("webmachine/include/webmachine_logger.hrl").
-include_lib("sample_requests.hrl").

valid_log_data() ->
  #wm_log_data{response_code = <<"200">>,
               method = 'GET',
               headers = ?SAMPLE_HEADERS,
               path = <<"this/is/the-path">>,
               notes = [{<<"org">>, <<"bobs_org">>},
                        {<<"req_id">>, <<"request_id">>},
                        {<<"perf_stats">>, [{<<"perf1">>, 1},
                                            {<<"perf2">>, 2}]
                        }]
              }.

valid_message_format_test_() ->
  [{"without annotations, generate_msg/1 should return the correct message",
      fun() ->
          ExpectedMsg = iolist_to_binary([<<"method=">>,<<"GET">>,<<"; ">>,
                      <<"path=">>,<<"this/is/the-path">>,<<"; ">>,
                      <<"status=">>,<<"200">>,<<"; ">>,
                      <<"user=">>,<<"undefined">>,<<"; ">>]),
          AnnotationFields = [],
          ActualMsg = oc_wm_request_logger:generate_msg(valid_log_data(), AnnotationFields),

          ?assertEqual(ExpectedMsg, iolist_to_binary(ActualMsg))
      end
    },
  {"with simple annotation, generate_msg/1 should return the correct message",
      fun() ->
          ExpectedMsg = iolist_to_binary([<<"method=">>,<<"GET">>,<<"; ">>,
                      <<"path=">>,<<"this/is/the-path">>,<<"; ">>,
                      <<"status=">>,<<"200">>,<<"; ">>,
                      <<"user=">>,<<"undefined">>,<<"; ">>,
                      <<"req_id">>,<<"=">>,<<"request_id">>,<<"; ">>]),
          AnnotationFields = [<<"req_id">>],
          ActualMsg = oc_wm_request_logger:generate_msg(valid_log_data(), AnnotationFields),

          ?assertEqual(ExpectedMsg, iolist_to_binary(ActualMsg))
      end
   },
   {"with proplist annotation, generate_msg/1 should return the correct message",
       fun() ->
           ExpectedMsg = iolist_to_binary([<<"method=">>,<<"GET">>,<<"; ">>,
                       <<"path=">>,<<"this/is/the-path">>,<<"; ">>,
                       <<"status=">>,<<"200">>,<<"; ">>,
                       <<"user=">>,<<"undefined">>,<<"; ">>,
                       <<"perf1">>,<<"=">>,<<"1">>,<<"; ">>,
                       <<"perf2">>,<<"=">>,<<"2">>,<<"; ">>
                   ]),
           AnnotationFields = [<<"perf_stats">>],
           ActualMsg = oc_wm_request_logger:generate_msg(valid_log_data(), AnnotationFields),


           ?assertEqual(ExpectedMsg, iolist_to_binary(ActualMsg))
       end
   },
  {"with invalid annotation key, generate_msg/1 should return the correct message",
      fun() ->
          ExpectedMsg = iolist_to_binary([<<"method=">>,<<"GET">>,<<"; ">>,
                      <<"path=">>,<<"this/is/the-path">>,<<"; ">>,
                      <<"status=">>,<<"200">>,<<"; ">>,
                      <<"user=">>,<<"undefined">>,<<"; ">>]),
          AnnotationFields = ["invalid_key"],
          ActualMsg = oc_wm_request_logger:generate_msg(valid_log_data(), AnnotationFields),

          ?assertEqual(ExpectedMsg, iolist_to_binary(ActualMsg))
      end
   },
   %% This is important because we get horrible failures if it doesn't
   {"note/2 should return undefined for nonexistant keys",
      fun() ->
          LogData = valid_log_data(),
          Notes = LogData#wm_log_data.notes,

          ?assertEqual(undefined, oc_wm_request_logger:note(notreal, Notes))
      end
    }
  ].
