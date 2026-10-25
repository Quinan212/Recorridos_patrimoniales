const fs = require('fs');
const vm = require('vm');
const assert = require('assert/strict');
vm.runInThisContext(fs.readFileSync('assets/mapa_3d/limite-area.js','utf8'));
const area = new LimiteArea(JSON.parse(fs.readFileSync('assets/mapa_3d/area-coverage.geojson','utf8')));
const catalog = JSON.parse(fs.readFileSync('assets/mapa_3d/area-catalog.json','utf8')).points;
for (const p of catalog) {
  assert(area.contains(p.location), `${p.name} debe permanecer dentro del óvalo`);
  assert.deepEqual(area.constrain(p.location), p.location, 'Nunca desplazar las coordenadas KML');
}
assert(area.contains([-58.01912,-31.39561]), 'Crossa II debe estar dentro del área');
for (const p of [[-58.1,-31.38],[-58.0,-31.38],[-58.04,-31.33],[-58.04,-31.43]]) {
  assert(!area.contains(p));
  const returned=area.constrain(p);
  assert(area.contains(returned), 'El regreso debe quedar dentro del óvalo');
  assert.deepEqual(area.constrain(returned), returned, 'El regreso no debe entrar en un bucle');
}
console.log('23 puntos KML y Crossa II dentro del óvalo; regreso válido en cuatro direcciones.');
