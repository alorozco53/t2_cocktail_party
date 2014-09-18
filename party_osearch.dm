diag_mod(party_osearch(Object),
[
%Situacion inicial (enciende el agente de personas)
    [
      id ==> is,	
      type ==> neutral,
      arcs ==> [
        empty : [execute('scripts/objectvisual.sh')] => find_object
      ]
    ],
% Buscar objeto
  [  
    id ==> find_object,
    type ==> recursive,
    embedded_dm ==> find(object, Object, [kitchen_table], [-20, 0, 20], [-30], object, [Object_found|Rest], Remaining_Positions, false, false, false, Status),
    arcs ==> [
      success : [say('Found object.')] => take_object(Object_found,left),
      error   : [say('Did not found object. Retrying.')] => find_object
    ]
  ],
% Tomar objeto
  [  
    id ==> take_object(O, Arm),
    type ==> recursive,
    embedded_dm ==>take(O, Arm, ObjTaken, Status),
    arcs ==> [
      success : [say('I took the object.'),execute('scripts/killvisual.sh')] => fs,
      error   : [say('Did not take object. Retrying.')] => take_object(O,right)
    ]
  ],
%Situacion final
  [
    id ==> fs,
    type ==> final
  ]
],
% Second argument: list of local variables
[
]
).
