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
      fs(_,_) : [set(client_list,[Name]), set(pos_to_come_back_list,[PX,PY,PR])] => busca_por_objetos(Drink)
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos(Object),
    type ==> recursive,
    embedded_dm ==> party_osearch(Object),
    arcs ==> [
      fs :  [say('I finished getting one object. I am going to deliver it.'),
             get(pos_to_come_back_list,PosList),get(client_list,[Client|_])] => entrega_de_orden(PosList,Client)
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden(PosList, Client),
    type ==> recursive,
    embedded_dm ==> party_p2search(PosList,Client),
    arcs ==> [
      fs : [set(pos_to_come_back_list,PT), set(client_list,CT), say('Finished delivering an object.'), get(rem_people,RP),
            (RP < 2 -> Sit = busca_persona_para_pedido | otherwise -> [say('I finished doing my services'), Sit = exit]),
	    inc(rem_people,RP)] => Sit
    ]
  ],
% Salir de la arena
  [  
    id ==> exit,
    type ==> recursive,
    embedded_dm ==> move([exit],Status),
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
    object_room ==> kitchen_table,
    pos_to_come_back_list ==> [],
    client_list ==> [],
    rem_people ==> none
  ]
).
