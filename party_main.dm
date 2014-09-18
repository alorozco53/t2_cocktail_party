diag_mod(party_main,
[
%Situacion inicial
  [
    id ==> is,	
    type ==> neutral,
    arcs ==> [
      empty : [tiltv(0),tilth(0),set(rem_people,0)] => detect_door
    ]
  ],
	 [  
      		id ==> detect_door,
      		type ==> recursive,
      		embedded_dm ==> detect_door(Status),
      		arcs ==> [
        			success : [say('The door is open')] => busca_persona_para_pedido,
        			error : [say('The door is still closed')] => detect_door
				
      			]
    	],
%Busca personas para pedido
  [
    id ==> busca_persona_para_pedido,
    type ==> recursive,
    embedded_dm ==> party_psearch(Name,Drink,[PX,PY,PR]),
    arcs ==> [
      fs(_,_) : [get(client_list,NameList), get(object_to_bring_list,ObjectList), get(pos_to_come_back_list,PosList),
	         append(NameList,[Name],NL), append(ObjectList,[Drink],OL), append(PosList,[[PX,PY,PR]],PL),
		 set(client_list,NL), set(object_to_bring_list,OL), set(pos_to_come_back_list,PL), get(rem_people,RP),
		 (RP < 2 -> Sit = busca_por_objetos(OL) | otherwise -> Sit = busca_persona_para-pedido),
	         inc(rem_people,RP)] => Sit
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos([]),
    type ==> neutral,
    embedded_dm ==> party_osearch(OL),
    arcs ==> [
      fs : say('I finished delivering. Yahooooooooo. Bye') => exit
    ]
  ],

  [
    id ==> busca_por_objetos([OH|OT]),
    type ==> recursive,
    prog ==> [say('now i will go get the next request')],
    embedded_dm ==> party_osearch(OH),
    arcs ==> [
      fs : say('I finished getting one object. I am going to deliver it.') => entrega_de_orden(OT)
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden(ObjectList),
    type ==> recursive,
    prog ==> [get(pos_to_come_back_list,[PH|PT]),get(client_list,[CH|CT])],
    embedded_dm ==> party_p2search(PH,CH),
    arcs ==> [
      fs : [set(pos_to_come_back_list,PT), set(client_list,CT), 
	    say('Finished delivering one object.') => busca_por_objetos(ObjectList)
    ]
  ],
% Salir de la arena
  [  
    id ==> exit,
    type ==> recursive,
    embedded_dm ==> move(exit,Status),
    arcs ==> [
      success : [say('I am in the exit')] => fs,
      error   : [say('Error in navigation')] => fs
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
    object_room ==> kitchen,
    object_to_bring_list ==> [],
    pos_to_come_back_list ==> [],
    client_list ==> [],
    rem_people ==> none
  ]
).