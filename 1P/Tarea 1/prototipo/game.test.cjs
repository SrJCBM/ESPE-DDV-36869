const {test}=require('node:test');
const assert=require('node:assert/strict');
const {Game,score,deck}=require('./game.js');
const cards=(...ranks)=>ranks.map(rank=>({rank:String(rank),suit:'♠'}));
function start(...ranks){const g=new Game();g.deal(cards(...ranks));return g;}
test('mazo: 52 cartas distintas',()=>{assert.equal(deck().length,52);assert.equal(new Set(deck().map(c=>c.rank+c.suit)).size,52)});
test('ases adaptables y figuras',()=>{assert.equal(score(cards('A','A',9)),21);assert.equal(score(cards('A','A','K')),12);assert.equal(score(cards('J','Q')),20)});
test('blackjack natural paga 3:2',()=>{const g=start('A',9,'K',7);assert.equal(g.balance,115);assert.equal(g.phase,'done');assert.equal(g.result,'blackjack')});
test('dos naturales empatan',()=>{const g=start('A','A','K','Q');assert.equal(g.balance,100);assert.equal(g.result,'push')});
test('natural del crupier',()=>{const g=start(10,'A',9,'K');assert.equal(g.balance,90);assert.equal(g.result,'lose')});
test('victoria y acciones repetidas no cobran dos veces',()=>{const g=start(10,10,9,7);assert.equal(g.balance,90);g.stand();assert.equal(g.balance,110);g.stand();g.hit();assert.equal(g.balance,110)});
test('empate devuelve apuesta',()=>{const g=start(10,10,8,8);g.stand();assert.equal(g.balance,100)});
test('exceso del jugador pierde inmediatamente',()=>{const g=start(10,10,8,7,9);g.hit();assert.equal(g.balance,90);assert.equal(g.phase,'done')});
test('crupier pide y se pasa',()=>{const g=start(10,10,8,6,10);g.stand();assert.equal(g.balance,110)});
test('crupier se planta en 17 suave',()=>{const g=start(10,'A',8,6,10);g.stand();assert.equal(g.dealer.length,2);assert.equal(g.balance,110)});
test('21 con tres cartas paga victoria normal',()=>{const g=start(7,10,4,8,10);g.hit();assert.equal(g.balance,110);assert.equal(g.result,'win')});
test('repartir durante turno no cambia mano ni saldo',()=>{const g=start(10,10,8,7);g.deal();assert.equal(g.balance,90);assert.equal(score(g.player),18)});
test('saldo insuficiente bloquea reparto y reinicio restaura',()=>{const g=new Game();g.balance=5;g.deal();assert.equal(g.balance,5);assert.equal(g.phase,'ready');g.reset();assert.equal(g.balance,100)});
