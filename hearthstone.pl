%Base de conocimientos:
nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

dano(criatura(_,Dano,_,_), Dano).
dano(hechizo(_,dano(Dano),_), Dano).
mana(jugador(_,_,Mana,_,_,_), Mana).
mana(criatura(_,_,_,Mana), Mana).
mana(hechizo(_,_,Mana), Mana).

cartasMazo(jugador(_,_,_,Cartas,_,_), Cartas).
cartasMano(jugador(_,_,_,_,Cartas,_), Cartas).
cartasCampo(jugador(_,_,_,_,_,Cartas), Cartas).

jugador(jugador(dante,50,13,[criatura(tigre,50,20,2), hechizo(darkHole,dano(50),2), hechizo(curacion,curar(20),6)],[hechizo(darkHole,dano(50),2), criatura(meteorBlackDragon,3500,2000,5)],[])).
jugador(jugador(aerius,50,13,[criatura(tigre,50,20,2),criatura(tigre,4,20,2)],[hechizo(curacion,cura(20),6),criatura(blueEyesWhiteDragon,3000,2500,4),hechizo(darkHole,dano(50),2)],[])).
/*
Los functores importantes:
Jugadores:
-----------
jugador(Nombre, PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo)

Cartas:
--------
criatura(Nombre, PuntosDaño, PuntosVida, CostoMana)
hechizo(Nombre, FunctorEfecto, CostoMana)

Efectos:
---------
daño(CantidadDaño)
cura(CantidadCura)

 */


%Punto 1:
tieneCarta(Jugador, Carta):-
    jugador(jugador(Jugador,_,_,CartasMazo,CartasMano,CartasCampo)),
    perteneceA(Carta,CartasMazo,CartasMano,CartasCampo).

perteneceA(Carta, CartasMazo,_,_):-
    member(Carta, CartasMazo).
perteneceA(Carta, _,CartasMano,_):-
    member(Carta, CartasMano).
perteneceA(Carta, _,_,CartasCampo):-
    member(Carta, CartasCampo).

%Punto 2:
esGuerrero(Jugador):-
    jugador(jugador(Jugador,_,_,_,_,_)),
    forall(tieneCarta(Jugador, Carta), esCriatura(Carta)).

esCriatura(criatura(_,_,_,_)).

    
%Punto 3:
postEmpezarTurno(Jugador, JugadorDespuesDeEmpezarElTurno):-
    jugador(Jugador),
    laPrimerCartaPasaALaManoYGanaPuntoDeMana(Jugador, JugadorDespuesDeEmpezarElTurno).

laPrimerCartaPasaALaManoYGanaPuntoDeMana(jugador(Nombre,PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo), jugador(Nombre, PuntosVida, PuntosMana2, CartasMazo2, CartasMano2, CartasCampo)):-
    nth0(0, CartasMazo, PrimerCartaMazo),
    agregarCarta(CartasMano, PrimerCartaMazo, CartasMano2),
    sacarPrimerCarta(PrimerCartaMazo,CartasMazo, CartasMazo2),
    sumarPuntoDeMana(PuntosMana, PuntosMana2).

sumarPuntoDeMana(PuntosDeMana, PuntosDeMana2):-
    PuntosDeMana2 is PuntosDeMana + 1.

%Punto 4:
puedeJugar(Jugador, Carta):- %No unifico acá al jugador pq como el jguador post turno no exsite rompe
    mana(Jugador, ManaJugador),
    mana(Carta, ManaCarta),
    ManaJugador >= ManaCarta.

vaAPoderJugar(Jugador, Carta):-
    postEmpezarTurno(Jugador, JugadorPostEmpezarTurno),
    puedeJugarInmediatamente(JugadorPostEmpezarTurno, Carta).
    

estaEnLaMano(Jugador, Carta):-
    cartasMano(Jugador, CartasMano),
    member(Carta, CartasMano).

%Punto 5:

%Punto 6:
cartaMasDanina(Jugador, Carta):-
    tieneCarta(Jugador,Carta),
    dano(Carta,Dano),
    forall(tieneCarta(Jugador, OtraCarta), esMenosDanina(OtraCarta, Dano)).

esMenosDanina(Carta,Dano):-
    dano(Carta, UnDano),
    UnDano =< Dano.
esMenosDanina(hechizo(_,curar(_),_),_).

%Punto 7:
%a)
jugarContra(Jugador, JugadorAfectado, Carta):-
    jugador(Jugador),
    hacerUsoDeLaCarta(Carta, Jugador, JugadorAfectado).

hacerUsoDeLaCarta(Carta, jugador(Nombre,PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo), jugador(Nombre, PuntosVida2, PuntosMana, CartasMazo, CartasMano, CartasCampo)):-
    dano(Carta, Dano),
    PuntosVida2 is PuntosVida - Dano.

%b)
jugar(Jugador, JugadorAfectado, Carta):-
    jugador(Jugador),
    puedeJugarInmediatamente(Jugador,Carta),
    jugarCarta(Jugador, JugadorAfectado, Carta).

jugarCarta(Jugador, JugadorAfectado, Carta):-
    efectoGeneralCartas(Jugador, JugadorIntermedio, Carta),
    quePasaConLaCarta(JugadorIntermedio, JugadorAfectado, Carta).

agregarCarta(Cartas, Carta, NuevasCartas):-
    append(Cartas, [Carta], NuevasCartas).

sacarPrimerCarta(Carta, Cartas, NuevasCartas):-
    append([Carta], NuevasCartas, Cartas).

efectoGeneralCartas(jugador(Nombre,PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo), jugador(Nombre, PuntosVida2, PuntosMana2, CartasMazo, NuevaMano, CartasCampo), Carta):-
    mana(Carta, Mana),
    reducirPuntosDeMana(PuntosMana, Mana, PuntosMana2),
    sacarCarta(Carta, CartasMano, CartasMano2),
    flatten(CartasMano2, NuevaMano), %Sin esto no funcionaba
    calcularVidaExtra(Carta, VidaAdicional),
    PuntosVida2 is PuntosVida + VidaAdicional.

cura(hechizo(_,cura(_),_)).

calcularVidaExtra(hechizo(_,cura(VidaAdicional),_), VidaAdicional).
calcularVidaExtra(Carta, 0):-
    not(cura(Carta)).

reducirPuntosDeMana(PuntosMana, Mana, PuntosMana2):-
    PuntosMana2 is PuntosMana - Mana.

quePasaConLaCarta(jugador(Nombre,PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo), jugador(Nombre,PuntosVida, PuntosMana, CartasMazo, CartasMano, CartasCampo2), criatura(NombreCarta, PuntosDano, PuntosVidaCarta, CostoMana)):-
    agregarCarta(CartasCampo,criatura(NombreCarta,PuntosDano,PuntosVidaCarta, CostoMana),CartasCampo2).
quePasaConLaCarta(Jugador, Jugador,hechizo(_,_,_)).

puedeJugarInmediatamente(Jugador,Carta):-
    estaEnLaMano(Jugador, Carta),
    puedeJugar(Jugador, Carta).

sacarCarta(_,[],_).
sacarCarta(Carta,[OtraCarta|RestoDeCartas],[OtraCarta, OtrasCartas]):-
    Carta \= OtraCarta,
    sacarCarta(Carta, RestoDeCartas, OtrasCartas).
sacarCarta(Carta,[Carta|RestoDeCartas],RestoDeCartas).
