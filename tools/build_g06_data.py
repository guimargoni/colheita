"""Build the small art fixture; no gameplay catalog or source PNG mutation."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT/'game/data/art/pilot/sample_v2.json').read_text())
data.update(id='g06.cozy.reference', contract='cozy.iso.g06', release_approved=False)
data['focus_bounds'] = [-134,-150,268,260]
data['camera_bounds'] = [-220,-220,220,210]
for key in ['chicken_0','chicken_1','chicken_2']:
    data['env'][key]['size'] = [20,23]
    data['env'][key]['pivot'] = [10,22]
data['kit'] = {
    'fence_x': {'rect':[814,164,322,302], 'size':[48,40], 'pivot':[8,20]},
    'fence_y': {'rect':[1186,164,320,300], 'size':[52,40], 'pivot':[41,20]},
    'bush': {'rect':[28,644,365,275], 'size':[40,30], 'pivot':[20,27]},
    'cypress': {'rect':[476,505,246,446], 'size':[38,68], 'pivot':[19,64]},
    'stones': {'rect':[807,699,317,185], 'size':[30,18], 'pivot':[15,16]},
}
data['path_tile'] = {'rect':[128,96,1518,727], 'size':[34,18], 'pivot':[17,9]}
paths = set()
for i in range(-2,6):
    paths.update([(-2,i),(5,i),(i,-2),(i,5)])
# Central one-cell alleys follow the same axes as plot centers.
for i in range(-1,6):
    paths.update([(1.5,i),(i,1.5)])
data['paths'] = [list(p) for p in sorted(paths)]
data['door_path'] = [[21+i*4.5,-50+i*4.34] for i in range(7)]
data['entities'] = [
    {'id':'house','kind':'house','at':[-3,-3],'footprint':[4,4],'origin':[-5,-5]},
    {'id':'orange.west','kind':'tree','at':[-5,0],'footprint':[2,2],'origin':[-6,-1]},
    {'id':'orange.east','kind':'tree','at':[1,-5],'footprint':[2,2],'origin':[0,-6]},
    {'id':'cypress.west','kind':'cypress','at':[-9,-2],'footprint':[1,1],'origin':[-9,-2]},
    {'id':'bush.west','kind':'bush','at':[-4,3],'footprint':[1,1],'origin':[-4,3]},
    {'id':'bush.east','kind':'bush','at':[4,-3],'footprint':[1,1],'origin':[4,-3]},
    {'id':'bush.front','kind':'bush','at':[7,5],'footprint':[1,1],'origin':[7,5]},
    {'id':'rocks.west','kind':'stones','at':[-3,4],'footprint':[1,1],'origin':[-3,4]},
    {'id':'rocks.east','kind':'stones','at':[7,1],'footprint':[1,1],'origin':[7,1]},
    {'id':'flowers.front','kind':'flowers','at':[2,7],'footprint':[1,1],'origin':[2,7]},
    {'id':'chicken','kind':'chicken','at':[-2,2],'footprint':[1,1],'origin':[-2,2]},
]
data['fences'] = []
# Two connected runs separated by a real entrance, outside active plots.
for axis, start, count in [('x',[-1,6],3),('y',[6,0],3)]:
    for i in range(count):
        at = [start[0]+(i*2 if axis=='x' else 0),start[1]+(i*2 if axis=='y' else 0)]
        end = [at[0]+(2 if axis=='x' else 0),at[1]+(2 if axis=='y' else 0)]
        data['fences'].append({'id':f'fence.{axis}.{i}','kind':'fence_'+axis,'at':at,'end':end})
data['effect_durations'] = {'plant':[0.18],'water':[0.24],'harvest':[0.12,0.18,0.18],'reward':[0.2],'button':[0.14]}
data['fx'] = {
    'plant': {'rect':[93,298,293,298], 'size':[28,28], 'pivot':[14,22]},
    'water': {'rect':[516,232,222,367], 'size':[22,36], 'pivot':[11,30]},
    'harvest_a': {'rect':[865,259,347,322], 'size':[34,32], 'pivot':[17,24]},
    'harvest_b': {'rect':[77,796,320,249], 'size':[34,28], 'pivot':[17,20]},
    'reward': {'rect':[553,871,143,139], 'size':[16,16], 'pivot':[8,8]},
    'button': {'rect':[923,863,208,110], 'size':[24,14], 'pivot':[12,7]},
}
data['scale_policy'] = {'human_reference_px':32,'chicken_height_px':23,'house_canvas_height_px':100,'tree_canvas_height_px':80,'mature_crop_canvas_px':18,'native_pixel_verified':False}
(ROOT/'game/data/art/g06/reference.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('G0.6 reference fixture written; four plots only')
