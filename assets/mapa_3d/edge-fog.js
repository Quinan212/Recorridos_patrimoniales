// Niebla geográfica de baja resolución: no usa filtros SVG ni texturas a DPR completo.
function createEdgeFog(map,coverage,settings={}){
 const options={inwardMeters:280,blurMeters:220,protectMeters:220,color:'#d4dbd8',protectedPoints:[],...settings};
 const host=map.getContainer(),canvas=document.createElement('canvas');
 canvas.className='edge-fog';canvas.setAttribute('aria-hidden','true');host.appendChild(canvas);
 const ctx=canvas.getContext('2d');
 const rings=coverage.features.flatMap(f=>f.geometry.type==='MultiPolygon'?f.geometry.coordinates.map(p=>p[0]):[f.geometry.coordinates[0]]);
 function inset(ring,distance){
  const latitude=ring.reduce((s,p)=>s+p[1],0)/ring.length,sx=111320*Math.cos(latitude*Math.PI/180),sy=111320,origin=ring[0];
  const r=ring.slice(0,-1).map(p=>[(p[0]-origin[0])*sx,(p[1]-origin[1])*sy]);
  const area=r.reduce((s,a,i)=>{const b=r[(i+1)%r.length];return s+a[0]*b[1]-b[0]*a[1];},0),sign=area>=0?1:-1;
  const shifted=r.map((p,i)=>{const previous=r[(i+r.length-1)%r.length],next=r[(i+1)%r.length],u=[p[0]-previous[0],p[1]-previous[1]],v=[next[0]-p[0],next[1]-p[1]],ul=Math.hypot(...u),vl=Math.hypot(...v),n1=[-sign*u[1]/ul,sign*u[0]/ul],n2=[-sign*v[1]/vl,sign*v[0]/vl],n=[n1[0]+n2[0],n1[1]+n2[1]],factor=distance/(n[0]*n2[0]+n[1]*n2[1]);return[origin[0]+(p[0]+factor*n[0])/sx,origin[1]+(p[1]+factor*n[1])/sy];});
  shifted.push(shifted[0]);return shifted;
 }
 function clipToView(ring,view){
  const area=view.reduce((s,a,i)=>{const b=view[(i+1)%view.length];return s+a[0]*b[1]-b[0]*a[1];},0),sign=area>=0?1:-1;
  let output=ring.slice(0,-1);const side=(a,b,p)=>sign*((b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0]));
  for(let i=0;i<view.length;i++){const a=view[i],b=view[(i+1)%view.length],input=output;output=[];if(!input.length)break;
   for(let j=0;j<input.length;j++){const p=input[j],q=input[(j+1)%input.length],sp=side(a,b,p),sq=side(a,b,q),pin=sp>=0,qin=sq>=0;if(pin)output.push(p);if(pin!==qin){const t=sp/(sp-sq);output.push([p[0]+t*(q[0]-p[0]),p[1]+t*(q[1]-p[1])]);}}
  }return output;
 }

 const fogRings=rings.map(r=>inset(r,options.inwardMeters));
 let enabled=true,lastSignature='',draws=0,totalMs=0,lastMs=0;
 function draw(force=false){
  if(!enabled)return;
  const w=host.clientWidth,h=host.clientHeight,c=map.getCenter();
  const signature=[w,h,c.lng,c.lat,map.getZoom(),map.getPitch(),map.getBearing()].join(',');
  if(!force && signature===lastSignature)return;
  lastSignature=signature;const start=performance.now();
  // Nunca más de 320 px en el lado mayor, independientemente de la densidad del teléfono.
  const pad=100,scale=Math.min(.5,320/(Math.max(w,h)+2*pad));
  const bw=Math.ceil((w+2*pad)*scale),bh=Math.ceil((h+2*pad)*scale);
  if(canvas.width!==bw||canvas.height!==bh){canvas.width=bw;canvas.height=bh;canvas.style.width=(w+2*pad)+'px';canvas.style.height=(h+2*pad)+'px';canvas.style.left=-pad+'px';canvas.style.top=-pad+'px';}
  ctx.setTransform(scale,0,0,scale,pad*scale,pad*scale);
  ctx.globalCompositeOperation='source-over';ctx.filter='none';ctx.fillStyle=options.color;
  ctx.fillRect(-pad,-pad,w+2*pad,h+2*pad);
  const scaleAt=p=>{const a=map.project(p),b=map.project([p[0]+100/(111320*Math.cos(p[1]*Math.PI/180)),p[1]]),d=map.project([p[0],p[1]+100/111320]);return Math.max(Math.hypot(b.x-a.x,b.y-a.y),Math.hypot(d.x-a.x,d.y-a.y))/100;};
  const blur=Math.max(4,Math.min(45,options.blurMeters*scaleAt([c.lng,c.lat])));
  const padding=Math.min(180,h*.2),view=[[-padding,-padding],[w+padding,-padding],[w+padding,h+padding],[-padding,h+padding]].map(p=>{const q=map.unproject(p);return[q.lng,q.lat];});
  ctx.globalCompositeOperation='destination-out';ctx.fillStyle='#000';ctx.filter='blur('+blur*scale+'px)';
  ctx.beginPath();
  for(const ring of fogRings){const clipped=clipToView(ring,view);if(clipped.length<3)continue;clipped.forEach((p,i)=>{const q=map.project(p);if(i)ctx.lineTo(q.x,q.y);else ctx.moveTo(q.x,q.y);});ctx.closePath();}
  ctx.fill();ctx.filter='none';
  for(const p of options.protectedPoints){
   const q=map.project(p),r=Math.max(12,Math.min(2200,options.protectMeters*scaleAt(p)));
   if(q.x+r<0||q.x-r>w||q.y+r<0||q.y-r>h)continue;
   const gradient=ctx.createRadialGradient(q.x,q.y,r*.55,q.x,q.y,r);
   gradient.addColorStop(0,'#000');gradient.addColorStop(1,'#0000');ctx.fillStyle=gradient;
   ctx.beginPath();ctx.arc(q.x,q.y,r,0,Math.PI*2);ctx.fill();
  }
  lastMs=performance.now()-start;totalMs+=lastMs;draws++;
 }
 // La firma evita trabajo mientras está quieto. Durante el gesto, la máscara
 // se actualiza en el mismo frame para que no se separe de la cartografía.
 const render=()=>draw(),resize=()=>draw(true);
 map.on('render',render);map.on('resize',resize);draw(true);
 return{protectedCount:options.protectedPoints.length,stats(){return{draws,averageMs:draws?totalMs/draws:0,lastMs,pixels:canvas.width*canvas.height};},setEnabled(value){enabled=!!value;canvas.style.display=enabled?'':'none';if(enabled)draw(true);},remove(){map.off('render',render);map.off('resize',resize);canvas.remove();}};
}
