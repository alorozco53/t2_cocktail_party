diag_mod(party_main,
[
%Situacion inicial
  [
    id ==> is,	
    type ==> neutral,
    arcs ==> [
      empty : [tiltv(0),tilth(0)] => detect_door
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
      fs(_,_) : [set(client_name,Name), set(object_to_bring,Drink), set(pos_to_come_back_to,[PX,PY,PR]), say('I will go get your order.')] => busca_por_objetos
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos,
    type ==> recursive,
    prog ==> [get(object_to_bring,Object)],
    embedded_dm ==> party_osearch(Object),
    arcs ==> [
      fs : say('I finished getting object. I am going to deliver it.') => entrega_de_orden
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden,
    type ==> recursive,
    prog ==> [get(pos_to_come_back_to,Pos),get(client_name,Pe)],
    embedded_dm ==> party_p2search(Pos,Pe),
    arcs ==> [
      fs : say('Finished delivering. Going out now.') => exit
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
    object_to_bring ==> none,
    pos_to_come_back_to ==> none,
    client_name ==> none
  ]
).	
