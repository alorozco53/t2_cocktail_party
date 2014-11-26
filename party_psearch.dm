diag_mod(party_psearch(Time, Name, Drink, PositionList, Status),
 [
%Situacion inicial (enciende el agente de personas)
   [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        %empty : [execute('scripts/upfollow.sh')] => place_to_see
         empty : [apply(generate_limit_time_em(T,L),[Time,LimitTime]),set(limit_time,LimitTime)] => place_to_see
      ]
    ],
% Moverse al lugar indicado para buscar personas
  [  
    id ==> place_to_see,
    type ==> recursive,
    embedded_dm ==> move([p2],Stat),
    arcs ==> [
      %success : [say('If you want something, raise your hand please.')] => find_person,
      success : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,ask_name,LimTime,RS,NS]),
                 say([RS,'If you want something, please come close to me and say your name'])] => NS,
      error   : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,place_to_see,LimTime,RS,NS]),
                 say(RS)] => NS
    ]
  ],
%Busca personas haciendo un gesto
  [  
    id ==> find_person,
    type ==> recursive,
    embedded_dm ==> scan(gesture, hand_up, [-30,0,30], [0], 5, [PX,PY,PZ,PV], false, true, Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,get_close_to_person([PX,PY,PZ]),LimTime,RS,NS]),
                 say([RS,'i found you']),execute('scripts/killvisual.sh'),sleep(3),execute('scripts/personvisual.sh')] => NS,
      error   : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,find_person,LimTime,RS,NS]),
                 say([RS,'Did not found anyone. Retrying.'])] => NS
    ]
  ],
% Acercarse a la persona
  [  
    id ==> get_close_to_person(P_position),
    type ==> recursive,
    embedded_dm ==> approach_person(P_position,Next_P_pos,Stat),
    arcs ==> [
      success : empty => ask_name,
      error   : [get(limit_time,LimTime),apply(verify_approach_ckp(A,B,C,D,E),[Stat,get_close_to_person(Next_P_pos),LimTime,RS,NS]),
                 say([RS,'Error in navigation. Retrying.'])] => NS
    ]
  ],
% Preguntar nombre de persona
  [
    id ==> ask_name,
    type ==> recursive,
    embedded_dm ==> ask('What is your name.',names,true,[],Name,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_ask_em(A,B,C,D,E),[Stat,memorize_person(Name),LimTime,RS,NS]),
                 say([RS,'Memorizing your face.']),tilt(20),execute('scripts/personvisual.sh')] => NS,
      error   : [get(limit_time,LimTime),apply(verify_ask_em(A,B,C,D,E),[Stat,ask_name,LimTime,RS,NS]),
                 say([RS,'Could not understand.'])] => NS
    ]
  ],
% Acercarse a la persona
  [  
    id ==> memorize_person(N),
    type ==> recursive,
    prog ==> [inc(counter,Counter)],
    embedded_dm ==> see_person(N,memorize,Stat),
    diag_mod ==> party_psearch(_,N,_,_,_),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_see_person_ckp(A,B,C,D,E,F),[Stat,ask_order,LimTime,Counter,RS,NS]),
                 say([RS,'i succeeded in memorizing your face']),set(memorized,true)] => NS,
      error   : [get(limit_time,LimTime),apply(verify_see_person_ckp(A,B,C,D,E,F),[Stat,memorize_person(N),LimTime,Counter,RS,NS]),
                 say(RS),execute('scripts/killvisual.sh'),
		 execute('scripts/personvisual.sh')] => NS
    ]
  ],
% Preguntar orden
  [
    id ==> ask_order,
    type ==> recursive,
    embedded_dm ==> ask('What do you want me to bring you.',drink,true,[],Drink,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_ask_em(A,B,C,D,E),[Stat,get_curr_pos(Drink),LimTime,RS,NS]),
                 say([RS,'I will bring your order soon.']),tilt(20)] => NS,
      error   : [get(limit_time,LimTime),apply(verify_ask_em(A,B,C,D,E),[Stat,ask_order,LimTime,RS,NS]),
                 say([RS,'Could not understand.'])] => NS
    ]
  ],
% Guardar posicion actual
  [  
    id ==> get_curr_pos(Drink),
    type ==> positionxyz,
    diag_mod ==> party_psearch(_,_,Drink,_,_),
    arcs ==> [
      pos(PX,PY,PR) : [execute('scripts/killvisual.sh'),set(position,[PX,PY,PR])] => success
    ]
  ],
%Situaciones finales
  [
    id ==> fs(camera_error),
    type ==> positionxyz,
    diag_mod ==> party_psearch(_,_,_,_,camera_error),
    arcs ==> [
      pos(X,Y,Z) : [say('since my camera is no longer working please keep close to my microphone')] => unify_error(X,Y,Z)
    ]
  ],

  [
    id ==> fs(time_is_up),
    type ==> positionxyz,
    diag_mod ==> party_psearch(_,_,_,_,time_is_up),
    arcs ==> [
      pos(X,Y,Z) : [say('my time is up please stand in front of me')] => unify_error(X,Y,Z)
    ]
  ],

  [
    id ==> unify_error(X,Y,Z),
    type ==> neutral,
    diag_mod ==> party_psearch(_,_,_,[X,Y,Z],_),
    arcs ==> [
      empty : empty => error
    ]
  ],

  [
    id ==> success,
    type ==> final,
    diag_mod ==> party_psearch(_,_,_,_,ok)
  ],

  [
    id ==> error,
    type ==> final
  ]
 ],
% Second argument: list of recognized(local variables)
 [
    limit_time ==> _,
    counter ==> 0,
    memorized ==> false,
    drink ==> null,
    position ==> null,
    error_status ==> null
  ]
).