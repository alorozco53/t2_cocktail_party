diag_mod(party_psearch(Name,Drink,[PX,PY,PR]),
  [
%Situacion inicial (enciende el agente de personas)
    [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        %empty : [execute('scripts/upfollow.sh')] => place_to_see
        empty : [execute('scripts/personvisual.sh')] => place_to_see
      ]
    ],
% Moverse al lugar indicado para buscar personas
  [  
    id ==> place_to_see,
    type ==> recursive,
    embedded_dm ==> move(p2,Status),
    arcs ==> [
      %success : [say('If you want something, raise your hand please.')] => find_person,
      success : [say('If you want something, please come close to me and say your name.')] => ask_name,
      error   : [say('Error in navigation. Retrying.')] => place_to_see
    ]
  ],
%Busca personas haciendo un gesto
  [  
    id ==> find_person,
    type ==> recursive,
    embedded_dm ==>scan(gesture , hand_up , [ -30, 0, 30 ] , [ 0 ] , 5 , [PX,PY,PZ,PV] , false , true , Status),
    arcs ==> [
      success : [say('I found you'),execute('scripts/killvisual.sh'),sleep(3),execute('scripts/personvisual.sh')] => get_close_to_person([PX,PY,PZ]),
      error   : [say('Did not found anyone. Retrying.')] => find_person
    ]
  ],
% Acercarse a la persona
  [  
    id ==> get_close_to_person(P_position),
    type ==> recursive,
    embedded_dm ==> approach_person(P_position,Next_P_pos,Status),
    arcs ==> [
      success : empty => ask_name,
      error   : [say('Error in navigation. Retrying.')] => get_close_to_person(Next_P_pos)
    ]
  ],
% Preguntar nombre de persona
  [
    id ==> ask_name,
    type ==> recursive,
    embedded_dm ==> ask('What is your name.',names,true,[],Name,Status),
    arcs ==> [
      success : [tiltv(20),say('Memorizing your face.')] => memorize_person(Name),
      error   : [say('Could not understand.')] => ask_name
    ]
  ],
% Acercarse a la persona
  [  
    id ==> memorize_person(N),
    type ==> recursive,
    embedded_dm ==> see_person(N,memorize,Status),
    arcs ==> [
      success : [execute('scripts/killvisual.sh')] => ask_order,
      error   : [say('Error in memorizing. Retrying.')] => memorize_person(N)
    ]
  ],
% Preguntar orden
  [
    id ==> ask_order,
    type ==> recursive,
    embedded_dm ==> ask('What do you want me to bring you.',drink,true,[],Drink,Status),
    arcs ==> [
      success : [say('I will bring your order soon.') ] => get_curr_pos(Drink),
      error   : [say('Could not understand.')] => ask_order
    ]
  ],
% Guardar posicion actual
  [  
    id ==> get_curr_pos(Drink),
    type ==> positionxyz,
    arcs ==> [
      pos(PX,PY,PR) : [execute('scripts/killvisual.sh')] => fs(Drink,[PX,PY,PZ])
    ]
  ],
%Situacion final
  [
    id ==> fs(Drink, Curr_pos),
    type ==> final,
    diag_mod ==> party_psearch(_,Drink,Curr_pos)
  ]
],

% Second argument: list of recognized(local variables)
  [
  ]
).
