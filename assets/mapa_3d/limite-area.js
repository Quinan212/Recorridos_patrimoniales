'use strict';
// Operar en metros evita deformar las distancias por la latitud de Concordia.
globalThis.LimiteArea = class {
  constructor(coverage) {
    const geometry=coverage.features[0].geometry;
    const ring=geometry.type==='MultiPolygon' ? geometry.coordinates[0][0] : geometry.coordinates[0];
    this.ring = ring.slice(0,-1);
    this.origin = this.ring[0];
    this.sx = 111320 * Math.cos(this.origin[1] * Math.PI / 180);
    this.sy = 111320;
    this.metric = this.ring.map(p=>this.toMeters(p));
    this.center = this.metric.reduce((sum,p)=>[sum[0]+p[0]/this.metric.length,sum[1]+p[1]/this.metric.length],[0,0]);
  }
  toMeters(p) {return [(p[0]-this.origin[0])*this.sx,(p[1]-this.origin[1])*this.sy];}
  fromMeters(p) {return [this.origin[0]+p[0]/this.sx,this.origin[1]+p[1]/this.sy];}
  contains(p) {
    const [x,y]=this.toMeters(p);
    let inside=false;
    for (let i=0,j=this.metric.length-1;i<this.metric.length;j=i++) {
      const a=this.metric[i],b=this.metric[j];
      if ((a[1]>y)!==(b[1]>y) && x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]) inside=!inside;
    }
    return inside;
  }
  constrain(point, inset=180) {
    if (this.contains(point)) return point;
    const p=this.toMeters(point);
    let closest, distance=Infinity;
    for (let i=0;i<this.metric.length;i++) {
      const a=this.metric[i],b=this.metric[(i+1)%this.metric.length];
      const v=[b[0]-a[0],b[1]-a[1]],length=v[0]*v[0]+v[1]*v[1];
      const t=length ? Math.max(0,Math.min(1,((p[0]-a[0])*v[0]+(p[1]-a[1])*v[1])/length)) : 0;
      const q=[a[0]+t*v[0],a[1]+t*v[1]],d=Math.hypot(p[0]-q[0],p[1]-q[1]);
      if (d<distance) {closest=q;distance=d;}
    }
    const v=[this.center[0]-closest[0],this.center[1]-closest[1]],length=Math.hypot(...v),step=Math.min(inset,length*.5);
    return this.fromMeters([closest[0]+step*v[0]/length,closest[1]+step*v[1]/length]);
  }
};
