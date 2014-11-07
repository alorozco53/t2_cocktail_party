diag_mod(party_psearch(Time,Name,Drink,[PX,PY,PR],Status),
  [
%Situacion inicial (enciende el agente de personas)
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        %empty : [execute('scripts/upfollow.sh')] => place_to_see
         empty : [apply(generate_time_limit_em(Time,LimitTime),LimitTime),set(limit_time,LimitTime),
                  set(locations,Locations),execute('scripts/personvisual.sh')] => place_to_see
      ]
    ],
% Moverse al lugar indicado para buscar personas
  [  
    id ==> place_to_see,
    type ==> recursive,
    embedded_dm ==> move([p2],Status),
    arcs ==> [
      %success : [say('If you want something, raise your hand please.')] => find_person,
      success : [get(limit_time,LimTime),apply(verify_move_em(Stat,ask_name,LimTime,RS,NS),[RS,NS])
                 say([RS,'If you want something, please come close to me and say your name'])] => NS,
      error   : [get(limit_time,LimTime),apply(verify_move_em(Stat,place_to_see,LimTime,RS,NS),[RS,NS])
                 say(RS)] => NS
    ]
  ],
%Busca personas haciendo un gesto
  [  
    id ==> find_person,
    type ==> recursive,
    embedded_dm ==> scan(gesture, hand_up, [-30,0,30], [0], 5, [PX,PY,PZ,PV], false, true, Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_scan_em(Status,get_close_to_person([PX,PY,PZ]),LimTime,RS,NS),[RS,NS]),
                 say([RS,'i found you']),execute('scripts/killvisual.sh'),sleep(3),execute('scripts/personvisual.sh')] => NS,
      error   : [get(limit_time,LimTime),apply(verify_scan_em(Stat,find_person,LimTime,RS,NS),[RS,NS]),
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
      error   : [get(limit_time,LimTime),apply(verify_approach_ckp(Stat,get_close_to_person(Next_P_pos),LimTime,RS,NS),[RS,NS]),
                 say([RS,'Error in navigation. Retrying.'])] => NS
    ]
  ],
% Preguntar nombre de persona
  [
    id ==> ask_name,
    type ==> recursive,
    embedded_dm ==> ask('What is your name.',names,true,[],Name,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_ask_em(Stat,memorize_person(Name),LimTime,RS,NS),[RS,NS]),
                 say([RS,'Memorizing your face.']),tilt(20)] => NS,
      error   : [get(limit_time,LimTime),apply(verify_ask_em(Stat,ask_name,LimTime,RS,NS),[RS,NS]),
                 say([RS,'Could not understand.'])] => NS
    ]
  ],
% Acercarse a la persona
  [  
    id ==> memorize_person(N),
    type ==> recursive,
    prog ==> [get(counter,Counter)]
    embedded_dm ==> see_person(N,memorize,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_see_person_ckp(Stat,ask_order,LimTime,Counter,RS,NS),[RS,NS]),
                 say([RS,'i succeeded in memorizing your face']),set(memorized,true)] => NS,
      error   : [get(limit_time,LimTime),apply(verify_see_person_ckp(Stat,memorize_person(N),LimTime,Counter,RS,NS),[RS,NS]),
                 say(RS),execute('scripts/killvisual.sh'),
		 execute('scripts/personvisual.sh'),inc(counter,Counter)] => NS
    ]
  ],
% Preguntar orden
  [
    id ==> ask_order,
    type ==> recursive,
    prog ==> [execute('scripts/killvisual.sh')],
    embedded_dm ==> ask('What do you want me to bring you.',drink,true,[],Drink,Stat),
    arcs ==> [
      success : [get(limit_time,LimTime),apply(verify_ask_em(Stat,get_curr_pos,LimTime,RS,NS),[RS,NS]),
                 say([RS,'I will bring your order soon.']),tilt(20),set(drink,Drink)] => NS,
      error   : [get(limit_time,LimTime),apply(verify_ask_em(Stat,ask_order,LimTime,RS,NS),[RS,NS]),
                 say([RS,'Could not understand.'])] => NS
    ]
  ],
% Guardar posicion actual
  [  
    id ==> get_curr_pos,
    type ==> positionxyz,
    arcs ==> [
      pos(PX,PY,PR) : [execute('scripts/killvisual.sh'),set(position,[PX,PY,PR]) => success
    ]
  ],
%Situaciones finales
  [
    id ==> fs(camera_error),
    type ==> positionxyz,
    arcs ==> [
      pos(X,Y,Z) : [say('since my camera is no longer working please keep close to my microphone'),
	            set(position,[PX,PY,PR]),set(error_status,camera_error)] => error
    ]
  ],

  [
    id ==> fs(time_is_up),
    type ==> positionxyz,
    arcs ==> [
      pos(X,Y,Z) : [say('my time is up please stand in front of me'),
	            set(position,[PX,PY,PR]),set(error_status,time_is_up)] => error
    ]
  ],

  [
    id ==> success,
    type ==> final,
    prog ==> [get(drink,Drink),get(position,Curr_pos)]
    diag_mod ==> party_psearch(_,Drink,Curr_pos,ok)
  ],

  [
    id ==> error,
    type ==> final,
    prog ==> [get(drink,Drink),get(position,Curr_pos),get(error_status,Erreur)]
    diag_mod ==> party_psearch(_,Drink,Curr_pos,Erreur)
  ],
  
],
% Second argument: list of recognized(local variables)
  [
    limit_time => 0,
    counter => 0,
    memorized => false,
    drink => null,
    position => null,
    error_status => null
  ]
).
