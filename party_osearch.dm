diag_mod(party_osearch(Time, CameraError, Object, Status),
[
%Situacion inicial (enciende el agente de personas)
    [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        empty : [apply(generate_time_limit_em(Time,LimitTime),LimitTime),set(limit_time,LimitTime),
		 execute('scripts/objectvisual.sh')] => find_object(CameraError)
      ]
    ],
% Buscar objeto
  [
    id ==> find_object(true),
    type ==> neutral,
    arcs ==> [
      empty : [say('my camera is damaged i cannot grab any drink')] => fs(camera_error)
    ]
  ],

  [  
    id ==> find_object(false),
    type ==> recursive,
    embedded_dm ==> find(object,[Object],[p3],[-20, 0, 20],[-30],object,[Object_found|Rest],Remaining_Positions,false,false,false,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_find_em(Stat,ts(Object_found,left),LimTime,RS,NS),[RS,NS]),
	         say([RS,'Found object.']),execute('scripts/killvisual.sh')] => NS,
      error   : [get(limit_time,LimTime),apply(verify_find_em(Stat,find_object(false),LimTime,RS,NS),[RS,NS]),
	         say([RS,'Did not found object. Retrying.'])] => NS
    ]
  ],
% Tomar objeto
  [  
    id ==> ts(O, Arm),
    type ==> recursive,
    embedded_dm ==>take(O, Arm, ObjTaken, Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_take_em(Stat,ObjTaken,Arm,LimTime,RS,NS),[RS,NS]),
	         say([RS,'I took the object.']),execute('scripts/killvisual.sh')] => NS
      error   : [get(limit_time,LimTime),apply(verify_find_em(Stat,O,Arm,LimTime,RS,NS),[RS,NS]),
	         say([RS,'Did not take object. Retrying.'])] => NS
    ]
  ],
%Situacion final
  [
    id ==> fs(Error),
    type ==> neutral,
    arcs ==> [
      empty : [(Error = camera_error -> set(camera_error,true) |
                otherwise -> set(camera_error,false)),say('sorry i failed in this mission')] => error
    ]
  ],

  [
    id ==> error,
    type ==> final,
    prog ==> [get(camera_error,CE),(CE = true -> Stat = camera_error | otherwise -> Stat = not_grasped)],
    diag_mod ==> party_osearch(_,_,_,Stat)
  ],
  
  [
    id ==> success,
    type ==> final,
    prog ==> [get(camera_error,CE)],
    diag_mod ==> party_osearch(_,_,_,ok)
  ]
],
% Second argument: list of local variables
[
   limit_time ==> 0,
   camera_error ==> false
]
).
