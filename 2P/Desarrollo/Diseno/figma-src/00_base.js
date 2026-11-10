// Helpers compartidos. Concatenar con una sola fase antes de use_figma.
const page=await figma.getNodeByIdAsync('0:1');await figma.setCurrentPageAsync(page);
await Promise.all([{family:'DM Sans',style:'Regular'},{family:'DM Sans',style:'Bold'},{family:'Cormorant Garamond',style:'SemiBold'},{family:'Outfit',style:'Medium'}].map(f=>figma.loadFontAsync(f)));
const created=[],mutated=[],removed=[];
const C={bg:'#0B2119',panel:'#16362A',deep:'#0C1B16',edge:'#5E694B',paper:'#EBDDBF',ink:'#263A2B',gold:'#D5B578',text:'#F1E4C9',muted:'#B9C4A8',error:'#F2B1A3',success:'#C9D89C',disabled:'#20392B'};
const rgb=h=>({r:parseInt(h.slice(1,3),16)/255,g:parseInt(h.slice(3,5),16)/255,b:parseInt(h.slice(5,7),16)/255});
const V={};for(const[k,i]of Object.entries({bg:5,panel:7,deep:9,edge:11,paper:13,ink:15,gold:17,text:19,muted:21,error:23,success:25,disabled:27}))V[k]=await figma.variables.getVariableByIdAsync('VariableID:7:'+i);
const paint=k=>figma.variables.setBoundVariableForPaint({type:'SOLID',color:rgb(C[k])},'color',V[k]);
const styles={title:'S:f6139b5238ae49e95bd2da3d2419efb6d5c865e6,',body:'S:2efe24993bd6c497cdd1294e04fde296d5d054fb,',label:'S:048bd348e4ab6a5ca61b4c1c4d29b20c35086d62,'};
const tr=n=>{created.push(n.id);return n;};
function descendants(n){return[n,...('findAll'in n?n.findAll(()=>true):[])];}
function fr(p,name,w,h,x=0,y=0,color=null){const n=tr(figma.createFrame());n.name=name;n.resize(w,h);n.fills=color?[paint(color)]:[];n.clipsContent=false;p.appendChild(n);n.x=x;n.y=y;return n;}
function auto(p,name,w,h,x=0,y=0,dir='VERTICAL'){const n=tr(figma.createAutoLayout(dir));n.name=name;n.resize(w,h);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.fills=[];p.appendChild(n);n.x=x;n.y=y;return n;}
async function tx(p,name,value,w,h,x,y,size=20,color='ink',role='body'){const n=tr(figma.createText());await n.setTextStyleIdAsync(styles[role]);n.characters=value;n.name=name;n.fontSize=size;n.lineHeight={unit:'PIXELS',value:Math.ceil(size*1.24)};n.textAutoResize='NONE';n.resize(w,h);n.fills=[paint(color)];p.appendChild(n);n.x=x;n.y=y;return n;}
function svg(p,name,content,w,h,x=0,y=0){const n=figma.createNodeFromSvg('<svg xmlns="http://www.w3.org/2000/svg" width="'+w+'" height="'+h+'" viewBox="0 0 '+w+' '+h+'">'+content+'</svg>');p.appendChild(n);n.name=name;n.x=x;n.y=y;created.push(...descendants(n).map(a=>a.id));return n;}
function erase(n){removed.push(n.id);n.remove();}
async function edit(n,value){for(const s of n.getStyledTextSegments(['fontName']))await figma.loadFontAsync(s.fontName);n.characters=value;mutated.push(n.id);}
const nodeAction=(id,navigation='OVERLAY')=>({type:'NODE',destinationId:id,navigation,transition:{type:'DISSOLVE',easing:{type:'EASE_OUT'},duration:.12}});
async function onClick(n,actions){await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions}]);mutated.push(n.id);}
