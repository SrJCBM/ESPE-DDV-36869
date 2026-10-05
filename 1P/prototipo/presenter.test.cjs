const {test}=require('node:test');
const assert=require('node:assert/strict');
const {Game}=require('./game.js');
const {Presenter}=require('./presenter.js');
const cards=(...ranks)=>ranks.map(rank=>({rank:String(rank),suit:'♠'}));
function gate(){let release;const promise=new Promise(r=>release=r);return {promise,release};}
test('reparto alternado; la vista no anuncia cartas ni totales antes de llegar',async()=>{
 const g=new Game(),events=[];let p;
 p=new Presenter(g,{card:async(target,c,hidden)=>{events.push([target,c.rank,hidden]);assert.equal(p.view.player.length+p.view.dealer.length,events.length-1);},change:()=>{}});
 await p.deal(cards(8,10,9,7));
 assert.deepEqual(events.map(e=>e[0]),['player','dealer','player','dealer']);
 assert.equal(events[3][2],true);assert.equal(p.view.dealer[1].rank,undefined);
 assert.equal(p.view.player.length,2);assert.equal(p.view.busy,false);
});
test('natural: saldo final e historial solo después de repartir y revelar',async()=>{
 const blocker=gate();const g=new Game();const p=new Presenter(g,{card:async()=>{},reveal:()=>blocker.promise});
 const job=p.deal(cards('A',9,'K',7));
 await new Promise(r=>setImmediate(r));
 assert.equal(p.view.balance,90);assert.equal(p.view.history.length,0);assert.equal(p.view.result,'');assert.equal(p.view.busy,true);
 blocker.release();await job;assert.equal(p.view.balance,115);assert.equal(p.view.result,'blackjack');assert.equal(p.view.history.length,1);
});
test('pulsaciones y reinicio durante animación no alteran la mano',async()=>{
 const blocker=gate();const g=new Game();const p=new Presenter(g,{card:()=>blocker.promise});
 const job=p.deal(cards(8,10,9,7));await p.deal();await p.hit();await p.stand();p.reset();assert.equal(g.round,1);assert.equal(g.player.length,2);
 blocker.release();await job;assert.equal(p.view.player.length,2);assert.equal(p.view.balance,90);
});
test('pedir 21: anima jugador, revela carta oculta y después cartas de la casa',async()=>{
 const events=[];const g=new Game();const p=new Presenter(g,{card:async(t,c)=>events.push(t+':'+c.rank),reveal:async c=>events.push('reveal:'+c.rank)});
 await p.deal(cards(7,10,4,6,10,2));events.length=0;await p.hit();
 assert.deepEqual(events,['player:10','reveal:6','dealer:2']);assert.equal(p.view.balance,110);assert.equal(p.view.result,'win');
});
test('plantarse conserva cartas y actualiza saldo una sola vez',async()=>{
 const g=new Game();const p=new Presenter(g);await p.deal(cards(10,10,9,7));await p.stand();await p.stand();assert.equal(p.view.balance,110);assert.equal(p.view.player.length,2);assert.equal(p.view.dealer.length,2);
});
test('reinicio restaura toda la vista y borra historial',async()=>{
 const p=new Presenter(new Game());await p.deal(cards('A',10,'K',7));p.reset();assert.equal(p.view.balance,100);assert.equal(p.view.player.length,0);assert.equal(p.view.history.length,0);assert.equal(p.view.round,0);
});
