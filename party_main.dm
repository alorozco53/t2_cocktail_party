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
    embedded_dm ==> party_psearch(180,Name,Drink,PosList,Status),
    arcs ==> [
      success : [append(CL,[Name],CLNew),append(DL,[Drink],DLNew),append(PL,[PosList],PLNew),
                 (RP < 3 -> Sit = busca_persona_para_pedido(CLNew,DLNew,PLNew) |
	          otherwise -> [Sit = busca_por_objetos(CLNew,DLNew,PLNew,false)])] => Sit,
      error : [append(CL,[Name],CLNew),append(DL,[Drink],DLNew),append(PL,[PosList],PLNew),get(camera_error,CamError),
	       apply(verify_psearch_ckp(S,N,R,D,E),[Status,busca_por_objetos(CLNew,DLNew,PLNew,CamError),RP,Action,RS,NS]),
	       say(RS)] => NextSit
    ]
  ],
%Busca por objeto
  [
    id ==> busca_por_objetos([], _, _, _),
    type ==> neutral,
    arcs ==> [
       empty : say('i finished delivering everything') => exit
    ]
  ],

  [
    id ==> busca_por_objetos([CH|CT], [DH|DT], [PH|PT], CameraError),
    type ==> recursive,
    embedded_dm ==> party_osearch(120,CameraError,DH,Status),
    arcs ==> [
      success : say('I finished getting one object. I am going to deliver it.') => entrega_de_orden([CH|CT],DT,[PH|PT],DH,CameraError),
      error : [(Status = camera_error -> set(camera_error,true) |
                otherwise -> []), say('i will try to get the next drink')] => busca_por_objetos(CT,DT,PT)
    ]
  ],
%Busca por persona para entregar pedido
  [
    id ==> entrega_de_orden([CH|CT], DL, [PH|PT], GraspedDrink, CamError),
    type ==> recursive,
    embedded_dm ==> party_p2search(90,CamError,GraspedDrink,PH,CH,Status),
    arcs ==> [
      success : say('Finished delivering one object.') => busca_por_objetos(CT,DL,PT,CamError),
      error : [(Status = camera_error -> set(camera_error,true) |
                otherwise -> []), say('i will try to get the next drink')] => busca_por_objetos(CT,DL,PT,CamError)
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
