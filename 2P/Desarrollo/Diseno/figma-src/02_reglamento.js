// Sustituir FAMILY_CONFIG por el resultado de 01_lum.js antes de ejecutar.
const family=FAMILY_CONFIG;
if(page.children.some(n=>n.name==='Reglamento / 02 · LOS PALOS'))throw new Error('El reglamento ya está aplicado. Usar su registro de IDs.');
const chapters=[{k:'mesa',title:'Sobrevive al Custodio',nav:'LA MESA',sub:'Objetivo y acciones',id:'21:7212'},{k:'palos',title:'Cuatro palos, cuatro decisiones',nav:'LOS PALOS',sub:'Efectos de las cartas'},{k:'puntos',title:'Cada decisión deja una marca',nav:'PUNTUACIÓN',sub:'Valores y patrones',id:'21:7232'},{k:'riesgo',title:'La Llave y la última oportunidad',nav:'LLAVES Y RIESGO',sub:'Devolver y cerrar'}];
const roots={},navs=[],closes=[],nexts=[];
async function action(p,name,label,detail,x,y,w,tone='Secundario'){
 const master=await figma.getNodeByIdAsync(family.variants[tone+'_Reposo']);const n=master.createInstance();p.appendChild(n);created.push(...descendants(n).map(a=>a.id));n.name=name;n.resize(w,80);n.x=x;n.y=y;n.setProperties({[family.properties.label]:label,[family.properties.detail]:detail});return n;
}
async function bindAction(n,actions,tone='Secundario'){await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions}]);mutated.push(n.id);}
function ruleBorder(p,w,h,x=0,y=0){return svg(p,'Filete del reglamento','<path d="M10 1H'+(w-10)+'l9 9V'+(h-10)+'l-9 9H10l-9-9V10Z" fill="none" stroke="'+C.ink+'" stroke-width=".7" opacity=".4"/>',w,h,x,y);}
async function stat(p,x,value,label,note){const f=fr(p,'Condición · '+label,250,120,x,170);ruleBorder(f,250,120);await tx(f,'Cifra',value,112,76,20,4,60,'ink','title');await tx(f,'Etiqueta',label,120,25,125,22,17,'ink','label');await tx(f,'Sentido',note,215,40,20,78,16);return f;}
for(let i=0;i<chapters.length;i++){
 const d=chapters[i],f=d.id?await figma.getNodeByIdAsync(d.id):fr(page,'Reglamento',1440,810);if(d.id){for(const n of [...f.children])erase(n);mutated.push(f.id);}roots[d.k]=f;f.name='Reglamento / '+String(i+1).padStart(2,'0')+' · '+d.nav;f.resize(1440,810);f.fills=[{type:'SOLID',color:rgb(C.bg),opacity:.88}];f.clipsContent=true;f.x=6600+i*1500;f.y=13200;
 const book=fr(f,'Libro de la casa',1240,680,100,65,'paper');book.clipsContent=false;
 const sidebar=fr(book,'Índice del reglamento',280,680,0,0,'deep');
 svg(sidebar,'Sello del reglamento','<g fill="none" stroke="'+C.gold+'" opacity=".55"><path d="M20 20h240v640H20Z"/><path d="M36 25h208M36 655h208"/><path d="M220 66v35l12 10h-44l12-10V66q0-18 10-18t10 18Z"/><path d="M203 115q7 10 14 0"/></g>',280,680);
 await tx(sidebar,'Nombre del libro','Reglas\nde la casa',225,108,30,38,42,'text','title');await tx(sidebar,'Encuentro','EL CUSTODIO · MESA I',225,25,30,160,13,'gold','label');
 const local=[];for(let j=0;j<chapters.length;j++){const n=await action(sidebar,'Capítulo '+chapters[j].k,String(j+1).padStart(2,'0')+'  '+chapters[j].nav,chapters[j].sub,30,218+j*88,220,i===j?'Primario':'Secundario');if(i!==j)local.push({node:n,target:chapters[j].k,tone:'Secundario'});else n.name='Capítulo actual';}navs.push(...local);
 const close=await action(sidebar,'Cerrar reglamento','VOLVER A LA MESA','Esc · sin gastar recursos',30,590,220,'Primario');closes.push(close);
 await tx(book,'Número de capítulo','REGLAMENTO DE LA CASA / '+String(i+1).padStart(2,'0'),860,24,320,25,13,'ink','label');
 await tx(book,'Título del capítulo',d.title,860,64,320,62,41,'ink','title');
 const next=await action(book,'Siguiente capítulo',i===3?'VOLVER AL INICIO':'SIGUIENTE CAPÍTULO',i===3?'Objetivo y acciones':chapters[i+1].sub,750,575,440,'Secundario');nexts.push({node:next,target:chapters[(i+1)%4].k});const done=await action(book,'Continuar partida','CONTINUAR PARTIDA','Conservar mano y campanadas',320,575,410,'Secundario');closes.push(done);
 await f.setReactionsAsync([{trigger:{type:'ON_KEY_DOWN',device:'KEYBOARD',keyCodes:[27]},actions:[{type:'CLOSE'}]}]);
 if(d.k==='mesa'){
  await stat(book,320,'17','UMBRAL','No lo excedas.');await stat(book,605,'200','META','Puntos acumulados.');await stat(book,890,'10','CAMPANADAS','Oportunidades iniciales.');
  const items=[['01','INICIAR MANO','1 campanada','Recibes dos cartas.'],['02','PEDIR','1 campanada','Añades una carta al final.'],['03','PLANTARSE','Gratis','Revelas y puntúas.']];
  for(let j=0;j<3;j++){const a=items[j],tile=fr(book,'Acción · '+a[1],250,160,320+j*285,320);ruleBorder(tile,250,160);await tx(tile,'Orden',a[0],48,48,16,8,34,'ink','title');await tx(tile,'Acción',a[1],174,28,64,20,17,'ink','label');await tx(tile,'Coste',a[2],218,42,16,65,27,'ink','title');await tx(tile,'Resultado',a[3],218,44,16,113,17);}
  await tx(book,'Baraja inicial','BARAJA INICIAL: 24 CARTAS · SEIS POR PALO',850,25,320,500,15,'ink','label');await tx(book,'Sin prisa','No es un temporizador. Puedes pensar, consultar y decidir a tu ritmo.',850,32,320,530,18);
 }
 if(d.k==='palos'){
  const suits=[['VELAS','3f595e1de3d394962132ca87f22862397e599e30','Cada Vela conservada\nañade +1 al multiplicador.'],['LLAVES','86886ac6cd2a1c244ef72a1ab6bed8b1d9690eef','Una devolución legal\npor mano, sin coste.'],['RELOJES','6b7f67f5342690f73080ac6bfd18436301208fb2','Valor impreso −1.\nEl mínimo efectivo es 1.'],['MÁSCARAS','54994e7ae574d3428b54ff32bc789fcdbf583a91','Valor oculto hasta cerrar\nla mano en esta mesa.']];
  for(let j=0;j<4;j++){const a=suits[j],tile=fr(book,'Palo · '+a[0],195,347,320+j*217,160);ruleBorder(tile,195,347);const panel=fr(tile,'Grabado del palo',165,215,15,15,'bg');const art=fr(panel,'Ilustración',165,215,0,0);art.fills=[{type:'IMAGE',imageHash:a[1],scaleMode:'FIT'}];const title=await tx(tile,'Palo',a[0],175,30,10,243,17,'ink','label');title.textAlignHorizontal='CENTER';const body=await tx(tile,'Efecto',a[2],175,60,10,282,16);body.textAlignHorizontal='CENTER';}
  await tx(book,'Valores','El número impreso y el palo cumplen funciones distintas.\nLos patrones siempre usan el valor efectivo de las cartas conservadas.',850,60,320,520,18);
 }
 if(d.k==='puntos'){
  await tx(book,'Ejemplo','EJEMPLO DE MANO CERRADA · UMBRAL 17',850,24,320,140,14,'ink','label');
  const a=fr(book,'Suma efectiva',230,132,320,175);ruleBorder(a,230,132);await tx(a,'Suma','17',190,73,20,2,62,'ink','title');await tx(a,'Cartas del ejemplo','Llaves 4 + Relojes 6 (ef. 5)\n+ Máscaras 8',195,48,20,78,15);
  await tx(book,'Multiplicar','×',45,72,560,201,51,'ink','title');const b=fr(book,'Multiplicador',250,132,610,175);ruleBorder(b,250,132);await tx(b,'Multiplicador','6',210,73,20,2,62,'ink','title');await tx(b,'Desglose','Base 1 + Punto exacto 3\n+ Ascenso 2',215,48,20,78,15);
  await tx(book,'Igual','=',45,72,872,201,48,'ink','title');const score=fr(book,'Puntos de esta mano',270,132,920,175,'panel');await tx(score,'Puntos','102',230,82,20,4,68,'gold','title');await tx(score,'Resultado','PUNTOS EN ESTA MANO',230,28,20,90,15,'text','label');
  await tx(book,'Exclusión','Punto exacto y Al filo son excluyentes. La base del multiplicador es 1.',850,26,320,321,16);
  const rules=[['PUNTO EXACTO · +3','La suma llega al umbral.'],['AL FILO · +2','La suma queda uno por debajo.'],['VELAS · +1 POR CARTA','Se suma a los patrones activados.'],['ASCENSO · +2','3+ cartas; toda la secuencia crece.'],['MANO LARGA · +2','5 o más cartas conservadas.'],['RACHA · +2','Las tres últimas son del mismo palo.']];
  for(let j=0;j<6;j++){const col=Math.floor(j/3),r=j%3,x=320+col*435,y=363+r*65;svg(book,'Marca del patrón','<path d="M0 8 8 0 16 8 8 16Z" fill="none" stroke="'+C.ink+'"/>',16,16,x,y+4);await tx(book,'Patrón',rules[j][0],390,24,x+25,y,16,'ink','label');await tx(book,'Condición',rules[j][1],390,30,x+25,y+25,15);}
 }
 if(d.k==='riesgo'){
  const left=fr(book,'La devolución',405,370,320,158);ruleBorder(left,405,370);await tx(left,'Título','Una Llave, una decisión',365,48,20,14,29,'ink','title');
  const rows=[['01','TRAS EL REPARTO','Elige una Llave inicial antes de actuar.'],['02','DESPUÉS DE PEDIR','Solo puede devolverse la Llave nueva.'],['03','AL DEVOLVER','Gratis, una vez; el reemplazo va al final.'],['04','PARA REEMPLAZAR','Debe haber otra carta distinta disponible.']];
  for(let j=0;j<4;j++){const r=rows[j],y=80+j*69;await tx(left,'Paso',r[0],38,36,20,y,25,'ink','title');await tx(left,'Momento',r[1],320,23,65,y,15,'ink','label');await tx(left,'Regla',r[2],320,45,65,y+24,16);}
  const right=fr(book,'Cierre de la mano',425,370,765,158,'panel');await tx(right,'Caso de incertidumbre','MÁSCARA OCULTA / UMBRAL 17',385,24,20,14,13,'text','label');await tx(right,'Intervalo del ejemplo','8 + ? → 9–18',385,58,20,40,39,'gold','title');await tx(right,'Riesgo del intervalo','Puedes entrar en Quiebra al plantarte.\nEl intervalo no indica probabilidades.',385,45,20,100,16,'text');const steps=[['1. RESUELVE LA MANO','Una Quiebra suma cero puntos.'],['2. COMPRUEBA LA META','200 o más: victoria, incluso con cero.'],['3. COMPRUEBA CAMPANADAS','Sin meta y con cero: termina el intento.']];
  for(let j=0;j<3;j++){await tx(right,'Paso de cierre',steps[j][0],385,23,20,157+j*64,14,'text','label');await tx(right,'Consecuencia',steps[j][1],385,42,20,181+j*64,15,'text');}
  await tx(book,'Aún hay decisión','Una devolución legal precede a la Quiebra. Con cero, todavía puedes plantarte.',850,30,320,535,16);
 }
}
for(const n of navs)await bindAction(n.node,[nodeAction(roots[n.target].id,'SWAP')],n.tone);
for(const n of nexts)await bindAction(n.node,[nodeAction(roots[n.target].id,'SWAP')]);
for(const n of closes)await bindAction(n,[{type:'CLOSE'}],n.parent.name==='Índice del reglamento'?'Primario':'Secundario');
return{createdNodeIds:created,mutatedNodeIds:mutated,removedNodeIds:removed,chapters:Object.fromEntries(Object.entries(roots).map(([k,n])=>[k,n.id])),navCount:navs.length,closeCount:closes.length};
