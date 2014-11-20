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
        			success : [say('The door is open')] => busca_persona_para_pedido([],[],[]),
        			error : [say('The door is still closed')] => detect_door
				
      			]
    	],
%Busca personas para pedido
  [
    id ==> busca_persona_para_pedido(CL,DL,PL),
    type ==> recursive,
    prog ==> [inc(rem_people,RP)],
    embedded_dm ==> party_psearch(90,Name,Drink,PosList,Status),
    arcs ==> [
      success : [append(CL,[Name],CLNew),append(DL,[Drink],DLNew),append(PL,[PosList],PLNew),
                 (RP < 3 -> Sit = busca_persona_para_pedido(CLNew,DLNew,PLNew) |
	          otherwise -> [Sit = busca_por_objetos(CLNew,DLNew,PLNew)])] => Sit,
      error : [append(CL,[Name],CLNew),append(DL,[Drink],DLNew),append(PL,[PosList],PLNew),
	       apply(verify_psearch_ckp(S,N,R,D,E),[Status,busca_por_objetos(CLNew,DLNew,PLNew),RP,Action,RS,NS]),
	       say(RS)] => NextSit
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos([], _, _),
    type ==> neutral,
    arcs ==> [
       empty : say('i finished delivering everything') => exit
    ]
  ],

  [
    id ==> busca_por_objetos([CH|CT], [DH|DT], [PH|PT]),
    type ==> recursive,
    prog ==> [say('now i will bring a requested drink'),get(camera_error,CameraError)],
    embedded_dm ==> party_osearch(120,CameraError,DH,Status),
    arcs ==> [
      success : say('I finished getting one object. I am going to deliver it.') => entrega_de_orden([CH|CT],DT,[PH|PT],DH),
      error : [(Status = camera_error -> set(camera_error,true) |
                otherwise -> []), say('i will try to get the next drink')] => busca_por_objetos(CT,DT,PT)
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden([CH|CT], DL, [PH|PT], GraspedDrink),
    type ==> recursive,
    prog ==> [get(camera_error,CamError)],
    embedded_dm ==> party_p2search(90,CamError,GraspedDrink,PH,CH,Status),
    arcs ==> [
      success : say('Finished delivering one object.') => busca_por_objetos(CT,DL,PT),
      error : [(Status = camera_error -> set(camera_error,true) |
                otherwise -> []), say('i will try to get the next drink')] => busca_por_objetos(CT,DL,PT)
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
% Situacion final
  [
    id ==> fs,
    type ==> final
  ]
],

% Second argument: list of local variables
  [
    object_room ==> null,
    rem_people ==> 0,
    camera_error ==> false
  ]
).