diag_mod(party_p2search(Time, CameraError, Drink, Position, Person, Status),
[
%Situacion inicial (enciende el agente de personas)
    [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        empty : [apply(generate_limit_time_em(T,L),[Time,LimitTime]),set(limit_time,LimitTime),
		 execute('scripts/personvisual.sh')] => place_to_start
      ]
    ],
% Moverse al lugar donde se vio a la persona la ultima vez
  [
    id ==> place_to_start,
    type ==> recursive,
    embedded_dm ==> move(Position,Stat),
    arcs ==> [
      success : [get(limit_time,LimitTime),apply(verify_move_em(A,B,C,D,E),[Stat,find_person(CameraError),LimitTime,RS,NS]),
                 say([RS,'Looking for the client who ordered this'])] => NS,
      error   : [get(limit_time,LimitTime),apply(verify_move_em(A,B,C,D,E),[Stat,place_to_start,LimitTime,RS,NS]),
                 say([RS,'Error in navigation. Retrying.'])] => NS
    ]
  ],
%Busca personas haciendo un gesto
  [
    id ==> find_person(true),
    type ==> neutral,
    arcs ==> [
      empty : say('since my camera doesnt work i will assume someone is in front of me') => hand_object(left)
    ]
  ],

  [  
    id ==> find_person(false),
    type ==> recursive,
    embedded_dm ==>find(person,Person,[p2],[-20,0,20],[0,20],recognize_with_approach,Found_Objects,Remaining_Positions,true,false,false,Stat),
    arcs ==> [
      success : [get(limit_time,LimitTime),apply(verify_find_em(A,B,C,D,E),[Stat,hand_object,LimitTime,RS,NS]),
                 say([RS,'I found you']),execute('scripts/killvisual.sh')] => NS,
      error   : [get(limit_time,LimitTime),apply(verify_find_em(A,B,C,D,E),[Stat,find_person(false),LimitTime,RS,NS]),
                 say([RS,'if youu hear me', Pe, 'please stand in front of me']),execute('scripts/killvisual.sh')] => NS
    ]
  ],
% Acercarse a la persona
  [  
    id ==> hand_object,
    type ==> recursive,
    embedded_dm ==> deliver(Drink,Position,handle,Stat),
    arcs ==> [
      success : [say('Enjoy it.')] => success,
      error   : [get(limit_time,LimitTime),apply(verify_deliver_em(A,B,C,D,E),[Stat,hand_object,LimitTime,RS,NS]),
                 say([RS,'Error in handing object. Retrying.'])] => NS
    ]
  ],
%Situacion final
  [
    id ==> fs(time_is_up),
    type ==> neutral,
    diag_mod ==> party_osearch(_,_,_,time_is_up)
    arcs ==> [
      empty : empty  => error
    ]
  ],

  [
    id ==> fs(Error),
    type ==> neutral,
    diag_mod ==> party_osearch(_,_,_,Error)
    arcs ==> [
      empty : empty  => error
    ]
  ],

  [
    id ==> error,
    type ==> final
  ],
  
  [
    id ==> success,
    type ==> final,
    diag_mod ==> party_osearch(_,_,_,ok)
  ]
],

% Second argument: list of recognized(local variables
  [
    limit_time ==> 0,
    camera_error ==> false
  ]
).