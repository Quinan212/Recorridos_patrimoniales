'use strict';
(() => {
  let map, fog, popup, catalog = [], markers = [], userMarker, coverage, mode3d = true;
  let selected = null, initializing = false, loaded = false, areaLimit, failure=null;
  const startedAt = performance.now();
  let readyMs = null;
  const post = (type, data = {}) => window.Patrimonio?.postMessage(JSON.stringify({type, ...data}));
  const load = async name => {
    const response = await fetch(name);
    if (!response.ok) throw Error('No se pudo cargar la cartografía local.');
    return response.json();
  };
  const locations = points => points.map(p => p.location);
  const bounds = points => {
    const p = locations(points);
    return [[Math.min(...p.map(q => q[0])), Math.min(...p.map(q => q[1]))], [Math.max(...p.map(q => q[0])), Math.max(...p.map(q => q[1]))]];
  };
  function clearSelection(notify = true) {
    const previous = popup;
    popup = null;
    previous?.remove();
    selected = null;
    for (const marker of markers) marker.getElement().classList.remove('active');
    if (notify) post('dismiss');
  }
  function showPopup(point) {
    const previous = popup;
    popup = null;
    previous?.remove();
    const card = document.createElement('article');
    card.className = 'popup-card';
    card.setAttribute('aria-label', point.name);
    card.style.setProperty('--popup-max-height', Math.min(420, map.getContainer().clientHeight - 60) + 'px');
    const body = document.createElement('div');
    body.className = 'popup-body';
    const tag = document.createElement('div');
    tag.className = 'popup-tag'; tag.textContent = 'Punto ' + point.number + ' · Patrimonio';
    const title = document.createElement('h2'); title.textContent = point.name;
    body.append(tag, title);
    if (point.address) {
      const address = document.createElement('p');
      address.className = 'popup-address'; address.textContent = point.address;
      body.append(address);
    }
    if (point.description) {
      const description = document.createElement('p');
      description.className = 'popup-description'; description.textContent = point.description;
      body.append(description);
    }
    if (/^imagenes\/\d+\.jpg$/.test(point.image || '')) {
      const image = document.createElement('img');
      image.className = 'popup-photo'; image.alt = point.name;
      image.src = new URL(point.image, document.baseURI).href;
      image.onerror = () => {image.remove(); current.setLngLat(point.location);};
      card.append(image);
    }
    const footer = document.createElement('div'); footer.className = 'popup-footer';
    const detail = document.createElement('button');
    detail.className = 'popup-detail'; detail.type = 'button';
    detail.textContent = 'Ver ficha completa';
    detail.onclick = event => {event.stopPropagation();post('openDetail', {id:point.id});};
    footer.append(detail); card.append(body,footer);
    const width = Math.min(320, map.getContainer().clientWidth - 28);
    const current = new maplibregl.Popup({offset:20,maxWidth:width+'px',closeOnClick:true,focusAfterOpen:false,className:'heritage-popup'})
      .setLngLat(point.location).setDOMContent(card).addTo(map);
    popup = current;
    current.getElement().querySelector('.maplibregl-popup-close-button')?.setAttribute('aria-label','Cerrar ventana');
    current.on('close', () => {
      if (popup !== current) return;
      popup = null; selected = null;
      for (const marker of markers) marker.getElement().classList.remove('active');
      post('dismiss');
    });
  }
  function select(id, notify = true) {
    const point = catalog.find(p => p.id === id);
    if (!point || !loaded) return;
    selected = id;
    for (const marker of markers) marker.getElement().classList.toggle('active', marker.getElement().dataset.id === id);
    showPopup(point);
    const offsetY = Math.min(170, map.getContainer().clientHeight * .24);
    map.flyTo({center:point.location, zoom:point.number===21 ? 17.1 : 18.1, pitch:mode3d ? 45 : 0, bearing:-10, offset:[0,offsetY], duration:500});
    if (notify) post('select', {id});
  }
  function center(zone = 'centro', duration = 500) {
    if (!loaded) return;
    clearSelection();
    const points = zone === 'all' ? catalog : catalog.filter(p => p.number !== 21);
    map.fitBounds(bounds(points), {padding:{top:50,left:45,right:45,bottom:110}, pitch:mode3d ? 40 : 0, bearing:zone === 'all' ? 40 : -10, maxZoom:16, duration});
  }
  function addPoints(points) {
    catalog = points;
    for (const marker of markers) marker.remove();
    markers = catalog.map(point => {
      const button = document.createElement('button');
      button.className = 'point'; button.textContent = point.number;
      button.classList.toggle('active', selected === point.id);
      button.dataset.id = point.id; button.dataset.source = point.source;
      button.dataset.location = JSON.stringify(point.location);
      button.setAttribute('aria-label', point.number + '. ' + point.name);
      button.onclick = event => {event.stopPropagation(); select(point.id);};
      return new maplibregl.Marker({element:button, anchor:'center'}).setLngLat(point.location).addTo(map);
    });
    if (loaded) {
      map.getSource('heritage').setData({type:'FeatureCollection',features:catalog.map(p=>({type:'Feature',geometry:{type:'Point',coordinates:p.location},properties:{number:p.number,name:p.name,id:p.id}}))});
      if (fog) fog.remove();
      fog = createEdgeFog(map, coverage, {protectedPoints:locations(catalog)});
      const point = catalog.find(p => p.id === selected);
      if (popup && point) showPopup(point);
    }
  }
  window.MapaPatrimonial = {
    async iniciar(points, initialId) {
      if (initializing) return;
      initializing = true;
      try {
        const [style, area, metadata] = await Promise.all([load('style-real-local.json'), load('area-coverage.geojson'), load('area-metadata.json')]);
        coverage = area;
        areaLimit = new LimiteArea(area);
        style.glyphs = new URL(style.glyphs, document.baseURI).href.replaceAll('%7B','{').replaceAll('%7D','}');
        for (const source of Object.values(style.sources)) {
          if (source.type === 'geojson' && typeof source.data === 'string') source.data = new URL(source.data,document.baseURI).href;
          if (source.tiles) source.tiles = source.tiles.map(url=>new URL(url,document.baseURI).href.replaceAll('%7B','{').replaceAll('%7D','}'));
        }
        maplibregl.setWorkerCount(2);
        // El trazado es una referencia de calles; no sustituye un itinerario peatonal.
        for (const layer of style.layers) if (layer.id.startsWith('recorrido-')) layer.layout = {...layer.layout, visibility:'none'};
        map = new maplibregl.Map({container:'map', style, center:[-58.0171,-31.3919], zoom:15.7,
          pitch:40, bearing:-10, minZoom:11, maxZoom:20, maxPitch:50,
          maxBounds:[[metadata.bounds[0]-.008,metadata.bounds[1]-.008],[metadata.bounds[2]+.008,metadata.bounds[3]+.008]],
          attributionControl:{compact:true}, fadeDuration:0, pixelRatio:1, maxTileCacheSize:32, maxTileCacheZoomLevels:2, renderWorldCopies:false});
        addPoints(points);
        const finishLoading = () => {
          if (loaded) return;
          loaded = true; addPoints(catalog);
          readyMs = performance.now() - startedAt;
          center('centro',0);
          if (initialId) select(initialId, true);
          document.body.dataset.ready = 'true';
          document.body.dataset.pointCount = catalog.length;
          post('ready', {count:catalog.length});
        };
        map.on('load', finishLoading);
        // Permitir explorar cuando la geometría esté lista, mientras terminan
        // de prepararse las etiquetas y los demás elementos secundarios.
        map.on('sourcedata', () => {
          if (!loaded && ['city','coverage'].every(id=>map.isSourceLoaded(id))) finishLoading();
        });
        map.on('error', e => post('error',{message:e.error?.message || 'No se pudo dibujar el mapa.'}));
        map.on('webglcontextlost', () => post('error',{message:'Se interrumpió el mapa 3D. Volvé a abrirlo.'}));
        map.on('moveend', () => {
          const center=map.getCenter(),location=[center.lng,center.lat];
          if (loaded && !areaLimit.contains(location)) map.easeTo({center:areaLimit.constrain(location),duration:550});
        });
        map.on('click', event => {
          if (!loaded) return;
          const feature = map.queryRenderedFeatures(event.point,{layers:['edificios-3d','nombres-patrimoniales']}).find(f=>f.properties.heritage_id || f.source === 'heritage');
          if (feature) select(feature.properties.heritage_id || feature.properties.id);
        });
      } catch (error) {failure=error.message;post('error',{message:error.message});}
    },
    select,
    niebla(enabled) {fog?.setEnabled(enabled);},
    // Solo diagnóstico, sin bucles ni muestreo mientras el usuario explora.
    async medirRendimiento() {
      if (!loaded) throw Error('Mapa pendiente');
      clearSelection(false);
      map.jumpTo({center:[-58.018136,-31.394185],zoom:18,pitch:45,bearing:-10});
      await new Promise(resolve=>setTimeout(resolve,1500));
      const deltas=[];let previous=0,running=true;
      const frame=now=>{if(previous)deltas.push(now-previous);previous=now;if(running)requestAnimationFrame(frame);};
      requestAnimationFrame(frame);
      for (const center of [[-58.0165,-31.3940],[-58.0193,-31.3936],[-58.018136,-31.394185]]) {
        map.easeTo({center,duration:900,easing:t=>t});
        await new Promise(resolve=>setTimeout(resolve,1000));
      }
      running=false;deltas.sort((a,b)=>a-b);
      return {readyMs,frames:deltas.length,medianMs:deltas[Math.floor(deltas.length*.5)],p95Ms:deltas[Math.floor(deltas.length*.95)],over50ms:deltas.filter(ms=>ms>50).length,fog:fog?.stats(),renderPixels:map.getCanvas().width*map.getCanvas().height};
    },
    cerrarSeleccion: clearSelection,
    center,
    actualizar: addPoints,
    zoom(delta) {if (loaded) map.zoomTo(map.getZoom() + delta,{duration:250});},
    modo(value) {mode3d = !!value; if (loaded) map.easeTo({pitch:mode3d ? 45 : 0, duration:500});},
    ubicacion(lng,lat) {
      if (!loaded) return;
      if (!userMarker) {const el = document.createElement('div'); el.className='user-location'; userMarker = new maplibregl.Marker({element:el}).setLngLat([lng,lat]).addTo(map);}
      userMarker.setLngLat([lng,lat]);
      // Evitar que un GPS fuera del recorte arrastre la cámara a una zona vacía.
      const inside = areaLimit.contains([lng,lat]);
      if (inside) map.flyTo({center:[lng,lat],zoom:17,duration:500});
      return inside;
    },
    estado() {return {ready:loaded,error:failure,count:catalog.length,selected,points:catalog,protectedPoints:fog?.protectedCount || 0,zoom:map?.getZoom(),pitch:map?.getPitch(),center:map?.getCenter().toArray(),fog: fog?.stats(),renderPixels:map ? map.getCanvas().width*map.getCanvas().height : 0,sources:map ? Object.fromEntries(Object.keys(map.getStyle().sources).map(id=>[id,map.isSourceLoaded(id)])) : {}};},
    destruir() {clearSelection(false);fog?.remove();map?.remove();loaded=false;},
  };
  post('boot');
})();
