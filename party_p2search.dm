diag_mod(party_p2search(Pos,Pe),
[
%Situacion inicial (enciende el agente de personas)
    [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        empty : [execute('scripts/personvisual.sh')] => place_to_start
      ]
    ],
% Moverse al lugar donde se vio a la persona la ultima vez
  [  
    id ==> place_to_start,
    type ==> recursive,
    embedded_dm ==> move(Pos,Status),
    arcs ==> [
      success : [say('Starting to look for person to deliver to.')] => find_person,
      error   : [say('Error in navigation. Retrying.')] => place_to_see
    ]
  ],
%Busca personas haciendo un gesto
  [  
    id ==> find_person,
    type ==> recursive,
    embedded_dm ==>find(person, Pe, [p2], [-20,0,20], [0,20], recognize_with_approach, Found_Objects, Remaining_Positions, true, false, false, Status),
    arcs ==> [
      success : [say('I found you'),execute('scripts/killvisual.sh')] => hand_object(left),
      error   : [say(['if youu hear me', Pe, 'please stand in front of me']),execute('scripts/killvisual.sh')] => hand_object(left)
    ]
  ],
% Acercarse a la persona
  [  
    id ==> hand_object(Hand),
    type ==> recursive,
    embedded_dm ==> relieve(Hand, Status),
    arcs ==> [
      success : [say('Enjoy.')] => fs,
      error   : [say('Error in handing object. Retrying.')] => hand_object(right)
    ]
  ],
%Situacion final
  [
    id ==> fs,
    type ==> final
  ]
],

% Second argument: list of recognized(local variables
  [
  ]
).
