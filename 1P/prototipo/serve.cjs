const http=require('node:http');
const fs=require('node:fs');
const path=require('node:path');
const allowed=new Set(['index.html','styles.css','game.js','presenter.js','app.js','assets/fonts/outfit.ttf','assets/fonts/dm-sans.ttf']);
const types={'.html':'text/html','.css':'text/css','.js':'text/javascript','.ttf':'font/ttf'};
http.createServer((req,res)=>{
 const name=req.url==='/'?'index.html':req.url.split('?')[0].slice(1);
 if(!allowed.has(name)){res.writeHead(404);res.end();return;}
 res.setHeader('Content-Type',(types[path.extname(name)]||'text/plain')+(['.ttf'].includes(path.extname(name))?'':'; charset=utf-8'));
 fs.createReadStream(path.join(__dirname,name)).on('error',()=>{res.writeHead(404);res.end();}).pipe(res);
}).listen(8766,'127.0.0.1',()=>console.log('http://127.0.0.1:8766'));
