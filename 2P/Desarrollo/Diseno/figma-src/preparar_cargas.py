"""Prepara y comprueba las cargas de Figma localmente, sin enviar peticiones.

Las fases 01 y 02 incluyen guardas para no duplicar trabajo ya aplicado.
No ejecuta las cargas en Figma ni modifica el DOCX.
"""
from pathlib import Path
import hashlib
import json
import subprocess

base = Path(__file__).resolve().parent
family = json.loads((base / 'estado-lum.json').read_text(encoding='utf-8'))
rules = json.loads((base / 'estado-rulesRevision.json').read_text(encoding='utf-8'))
prior = json.loads((base.parent / 'validacion-figma.json').read_text(encoding='utf-8'))
config = {'variants': family['variants'], 'properties': family['properties']}
audit = {
    'screens': prior['screens'], 'chapters': rules['chapters'],
    'cards': ['13:52', '13:2', '13:21', '13:69', '13:86', '20:446'],
    'buttons': list(family['variants'].values()),
    'cardSet': family['cardSet'], 'actionSet': family['actionSet'],
}
out = base / 'cargas_preparadas'
out.mkdir(exist_ok=True)
manifest = []
for name in ['01_lum.js', '01b_integrar_acciones.js', '02_reglamento.js', '03_validar.js']:
    phase = (base / name).read_text(encoding='utf-8')
    phase = phase.replace('const family=FAMILY_CONFIG;', 'const family=' + json.dumps(config, ensure_ascii=False) + ';')
    phase = phase.replace('const cfg=VALIDATION_CONFIG;', 'const cfg=' + json.dumps(audit, ensure_ascii=False) + ';')
    source = (base / '00_base.js').read_text(encoding='utf-8') + '\n' + phase
    if len(source) > 50000:
        raise ValueError(f'{name}: supera el límite de entrada de use_figma')
    dest = out / name
    dest.write_text(source, encoding='utf-8')
    subprocess.run(['node', '-e', "const f=require('fs'); const A=Object.getPrototypeOf(async function(){}).constructor;new A(f.readFileSync(process.argv[1],'utf8'));", str(dest)], check=True, capture_output=True)
    manifest.append({'file': name, 'characters': len(source), 'sha256': hashlib.sha256(source.encode('utf-8')).hexdigest(), 'syntax': 'ok'})
(out / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps({'prepared': len(manifest), 'syntax': 'ok', 'figma_requests': 0}))
