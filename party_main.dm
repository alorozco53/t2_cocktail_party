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
      fs(_,_) : [get(client_list,CL),get(drink_list,DL),get(pos_to_come_back_list,PL),
	         append(CL,[Name],CLNew),append(DL,[Drink],DLNew),append(PL,[[PX,PY,PR]],PLNew),
                 set(client_list,CLNew),set(drink_list,DLNew),set(pos_to_come_back_list,PLNew),get(rem_people,RP),
                 (RP < 2 -> Sit = busca_persona_para_pedido |
	          otherwise -> [say('now i will bring your requests'), Sit = busca_por_objetos(CLNew,DLNew,PLNew)]),
	         inc(rem_people,RP)] => Sit
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos([],_,_),
    type ==> neutral,
    arcs ==> [
       empty : say('i finished delivering everything') => exit
    ]
  ],

  [
    id ==> busca_por_objetos(CL, [DH|DT], PL),
    type ==> recursive,
    embedded_dm ==> party_osearch(DH),
    arcs ==> [
      fs :  say('I finished getting one object. I am going to deliver it.') => entrega_de_orden(CL,DT,PL)
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden([CH|CT], DL, [PH|PT]),
    type ==> recursive,
    embedded_dm ==> party_p2search(PH,CH),
    arcs ==> [
      fs : say('Finished delivering one object.') => busca_por_objeto(CT,DL,PT)
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
    drink_list ==> [],
    rem_people ==> none
  ]
).