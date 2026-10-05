(function(root){
'use strict';
class Presenter {
 constructor(game,hooks={}){this.game=game;this.hooks=hooks;this.clear();}
 clear(){this.view={player:[],dealer:[],balance:this.game.balance,round:this.game.round,history:[],phase:'ready',busy:false,result:'',title:'Todo listo',message:'Reparte la primera mano para empezar.',step:'Esperando reparto'};}
 emit(){if(this.hooks.change)this.hooks.change(this.view);}
 reset(){if(this.view.busy)return;this.game.reset();this.clear();if(this.hooks.clear)this.hooks.clear();this.emit();}
 async card(target,index,concealed=false){const card=this.game[target][index];this.view.step=target==='player'?'Repartiendo tu carta':'Repartiendo a la casa';this.emit();if(this.hooks.card)await this.hooks.card(target,card,concealed);this.view[target].push(concealed?{concealed:true}:{...card});this.emit();}
 async resolve(){this.view.title='Turno de la casa';this.view.message='La casa revela su mano y se planta en 17.';this.view.step='Revelando la carta';this.emit();if(this.view.dealer[1]?.concealed){if(this.hooks.reveal)await this.hooks.reveal(this.game.dealer[1]);this.view.dealer[1]={...this.game.dealer[1]};this.emit();}for(let i=this.view.dealer.length;i<this.game.dealer.length;i++)await this.card('dealer',i);}
 finishView(){Object.assign(this.view,{balance:this.game.balance,phase:this.game.phase,history:[...this.game.history],result:this.game.result,message:this.game.message,title:this.game.phase==='player'?'Tu turno':({win:'Ganaste la mano',blackjack:'Blackjack',push:'Empate',lose:'Gana la casa',bust:'Te pasaste'}[this.game.result]||'Todo listo'),step:this.game.phase==='player'?'Elige tu siguiente movimiento':'Mano terminada',busy:false});this.emit();}
 async deal(sequence){if(this.view.busy||this.game.phase==='player'||this.game.balance<this.game.bet)return;this.game.deal(sequence);Object.assign(this.view,{player:[],dealer:[],round:this.game.round,balance:this.view.balance-10,phase:'dealing',busy:true,result:'',title:'Repartiendo',message:'Una carta para ti. Una para la casa.'});if(this.hooks.clear)this.hooks.clear();this.emit();try{await this.card('player',0);await this.card('dealer',0);await this.card('player',1);await this.card('dealer',1,true);if(this.game.phase==='done')await this.resolve();}finally{this.finishView();}}
 async hit(){if(this.view.busy||this.game.phase!=='player')return;this.view.busy=true;this.view.title='Una carta más';this.view.message='Espera a que llegue tu carta.';this.emit();const index=this.game.player.length;this.game.hit();try{await this.card('player',index);if(this.game.phase==='done')await this.resolve();}finally{this.finishView();}}
 async stand(){if(this.view.busy||this.game.phase!=='player')return;this.view.busy=true;this.emit();this.game.stand();try{await this.resolve();}finally{this.finishView();}}
}
if(typeof module!=='undefined'&&module.exports)module.exports={Presenter};else root.BlackjackPresenter={Presenter};
})(globalThis);
