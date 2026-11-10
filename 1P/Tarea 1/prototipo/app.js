'use strict';
const {Game,score}=Blackjack;
const {Presenter}=BlackjackPresenter;
const game=new Game();
const $=id=>document.getElementById(id);
$('motion-toggle').checked=true;
const motionEnabled=()=>$('motion-toggle').checked;
const labels={win:'Victoria',blackjack:'Blackjack',push:'Empate',lose:'Derrota',bust:'Te pasaste'};
const suitNames={'♠':'picas','♥':'corazones','♦':'diamantes','♣':'tréboles'};
const format=new Intl.NumberFormat('es-EC');
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
function emptyHands(){for(const id of ['player','dealer']){const hand=$(id);hand.replaceChildren();for(let i=0;i<2;i++){const slot=document.createElement('div');slot.className='card-slot';slot.setAttribute('aria-hidden','true');hand.append(slot);}}}
function back(el){el.className='card back';el.replaceChildren();const pattern=document.createElement('div');pattern.className='back-pattern';const mark=document.createElement('span');mark.className='back-emblem';const symbol=document.createElement('span');symbol.textContent='♠';mark.append(symbol);pattern.append(mark);el.append(pattern);}
function face(el,card){el.className='card'+(['♥','♦'].includes(card.suit)?' red':'');el.replaceChildren();const corner=document.createElement('span');corner.className='corner';corner.append(document.createTextNode(card.rank));const suit=document.createElement('small');suit.textContent=card.suit;corner.append(suit);const pip=document.createElement('div');pip.className='pips';pip.setAttribute('aria-hidden','true');const n=Number(card.rank);if(n){pip.dataset.count=n;for(let i=0;i<n;i++){const mark=document.createElement('span');mark.textContent=card.suit;pip.append(mark);}}else{pip.classList.add('royal');pip.textContent=card.rank==='A'?card.suit:card.rank;const emblem=document.createElement('small');emblem.textContent=card.suit;if(card.rank!=='A')pip.append(emblem);}const bottom=corner.cloneNode(true);bottom.classList.add('bottom');bottom.setAttribute('aria-hidden','true');el.append(corner,pip,bottom);el.removeAttribute('aria-hidden');el.setAttribute('role','img');el.setAttribute('aria-label',card.rank+' de '+suitNames[card.suit]);}
async function animate(el,keyframes,duration){if(!motionEnabled()||!el.animate)return;const motion=el.animate(keyframes,{duration,easing:'cubic-bezier(.22,.75,.25,1)',fill:'both'});try{await motion.finished;}finally{motion.cancel();}}
async function flip(el,card){await animate(el,[{transform:'scaleX(1)'},{transform:'scaleX(0)'}],110);face(el,card);await animate(el,[{transform:'scaleX(0)'},{transform:'scaleX(1)'}],180);}
async function dealCard(target,card,concealed){const hand=$(target);let slot=hand.querySelector('.card-slot');if(!slot){slot=document.createElement('div');slot.className='card-slot';hand.append(slot);}back(slot);slot.setAttribute('aria-hidden','true');
 if(!motionEnabled())await wait(250);
 const origin=$('deck').getBoundingClientRect();const destination=slot.getBoundingClientRect();const dx=origin.left+origin.width/2-destination.left-destination.width/2,dy=origin.top+origin.height/2-destination.top-destination.height/2;
 await animate(slot,[{transform:`translate(${dx}px,${dy}px) rotate(14deg) scale(.72)`,opacity:1},{transform:`translate(${dx*.8}px,${dy*.8}px) rotate(8deg) scale(.85)`,opacity:1,offset:.18},{transform:'translate(0,0) rotate(0deg) scale(1)',opacity:1}],650);
 if(concealed){slot.removeAttribute('aria-hidden');slot.setAttribute('role','img');slot.setAttribute('aria-label','Carta oculta');}else await flip(slot,card);
 if(motionEnabled())await wait(80);
}
function render(view){const busy=view.busy;const playing=view.phase==='player';$('balance').textContent=format.format(view.balance);$('round').textContent=view.round?'Mano '+String(view.round).padStart(2,'0'):'Esperando reparto';const visibleDealer=view.dealer.filter(c=>!c.concealed);$('dealer-score').textContent=visibleDealer.length?score(visibleDealer)+(view.dealer.some(c=>c.concealed)?' + ?':''):'—';$('player-score').textContent=view.player.length?score(view.player):'—';$('result-title').textContent=view.title;$('message').textContent=view.message+(!busy&&view.phase==='done'&&view.balance<10?' Reinicia para seguir jugando.':'');$('step').textContent=view.step;$('bet-value').textContent=busy||playing?'10 fichas':'0 fichas';$('phase-label').textContent=busy?'Repartiendo':playing?'Tu turno':view.phase==='done'?'Terminada':'Listo';$('deal').hidden=playing;$('deal').disabled=busy||view.balance<10;$('deal').innerHTML=(busy?'Repartiendo…':view.phase==='ready'?'Repartir':'Siguiente mano')+' <span aria-hidden="true">♠</span>';$('hit').hidden=!playing;$('stand').hidden=!playing;$('hit').disabled=busy;$('stand').disabled=busy;$('reset').disabled=busy;$('motion-toggle').disabled=busy;$('mesa').setAttribute('aria-busy',String(busy));document.body.dataset.phase=busy?'busy':playing?'playing':view.result||'ready';
 $('history-count').textContent=view.history.length;$('history').replaceChildren();if(!view.history.length){const li=document.createElement('li');li.className='empty';li.textContent='Tu primera mano empieza aquí.';$('history').append(li);}for(const h of view.history){const li=document.createElement('li');const text=document.createElement('span');const number=document.createElement('small');number.textContent=String(h.round).padStart(2,'0');text.append(number,document.createTextNode(labels[h.result]));const net=document.createElement('strong');net.className=h.net>0?'positive':h.net<0?'negative':'';net.textContent=(h.net>0?'+':'')+format.format(h.net);li.append(text,net);$('history').append(li);}}
const presenter=new Presenter(game,{change:render,clear:emptyHands,card:dealCard,reveal:card=>flip($('dealer').children[1],card)});
async function act(action){if(presenter.view.busy)return;try{await presenter[action]();}catch(error){console.error('No se pudo completar la presentación de la mano.',error);$('message').textContent='No se pudo mostrar la mano. Reinicia la sesión para continuar.';}const view=presenter.view;(view.phase==='player'?$('hit'):view.balance<10?$('reset'):$('deal')).focus({preventScroll:true});}
$('deal').addEventListener('click',()=>act('deal'));
$('hit').addEventListener('click',()=>act('hit'));
$('stand').addEventListener('click',()=>act('stand'));
$('reset').addEventListener('click',()=>{if(presenter.view.busy)return;if(confirm('¿Reiniciar con 100 fichas y borrar el historial?')){presenter.reset();$('deal').focus({preventScroll:true});}});
$('rules-open').addEventListener('click',()=>$('rules').showModal());$('rules-close').addEventListener('click',()=>$('rules').close());
emptyHands();render(presenter.view);

