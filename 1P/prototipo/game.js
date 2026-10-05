(function(root){
'use strict';
function deck(){return ['♠','♥','♦','♣'].flatMap(suit=>['A','2','3','4','5','6','7','8','9','10','J','Q','K'].map(rank=>({rank,suit})));}
function score(hand){let total=0,aces=0;for(const c of hand){if(c.rank==='A'){total+=11;aces++;}else total+=['J','Q','K'].includes(c.rank)?10:Number(c.rank);}while(total>21&&aces){total-=10;aces--;}return total;}
function shuffled(){const d=deck();for(let i=d.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[d[i],d[j]]=[d[j],d[i]];}return d;}
class Game{
 constructor(){this.reset();}
 reset(){this.balance=100;this.bet=10;this.phase='ready';this.player=[];this.dealer=[];this.round=0;this.result='';this.message='La noche empieza con una carta.';this.history=[];}
 deal(sequence){if(this.phase==='player'||this.balance<this.bet)return;this.pile=sequence?[...sequence]:shuffled();this.balance-=this.bet;this.player=[];this.dealer=[];this.result='';this.round++;this.phase='player';this.player.push(this.pile.shift());this.dealer.push(this.pile.shift());this.player.push(this.pile.shift());this.dealer.push(this.pile.shift());this.message='Tu turno. Pide otra carta o conserva tu mano.';const p=score(this.player)===21,d=score(this.dealer)===21;if(p||d)this.finish(p&&d?'push':p?'blackjack':'lose');}
 hit(){if(this.phase!=='player')return;this.player.push(this.pile.shift());const total=score(this.player);if(total>21)this.finish('bust');else if(total===21)this.stand();else this.message='Tienes '+total+'. ¿Otra carta o te plantas?';}
 stand(){if(this.phase!=='player')return;while(score(this.dealer)<17)this.dealer.push(this.pile.shift());const p=score(this.player),d=score(this.dealer);this.finish(d>21||p>d?'win':p===d?'push':'lose');}
 finish(result){if(this.phase!=='player')return;this.result=result;this.phase='done';const payout={win:20,blackjack:25,push:10,lose:0,bust:0}[result];this.balance+=payout;this.message={win:score(this.dealer)>21?'El crupier se pasó. La mano es tuya.':'Tu mano supera a la casa.',blackjack:'As y diez. Una entrada perfecta.',push:'Mismo valor. Recuperas tu apuesta.',lose:'Esta vez, la casa gana.',bust:'Superaste 21. La casa se lleva la apuesta.'}[result];this.history.unshift({round:this.round,result,net:payout-this.bet});this.history=this.history.slice(0,5);}
}
const api={Game,score,deck};if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.Blackjack=api;
})(globalThis);
