"""Real loopback integration tests. Never logs or commits account credentials."""
import argparse,json,secrets,socket,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--port',type=int,default=16662);a=p.parse_args()
serial=0;checks=0

def rpc(token,method,args=None,request_id=None):
 global serial
 serial+=1
 msg={'method':method,'token':token,'args':args or {},'request_id':request_id or f'qa.{serial}'}
 with socket.create_connection(('127.0.0.1',a.port),timeout=4) as s:
  s.sendall((json.dumps(msg)+'\n').encode()); data=b''
  while b'\n' not in data:
   part=s.recv(65536)
   if not part:break
   data+=part
 return json.loads(data.split(b'\n')[0])
def ck(ok,text):
 global checks
 checks+=1
 if not ok:raise AssertionError(text)
def farm(t,type,**args):return rpc(t,'farm_command',{'type':type,**args})
def snap(t):return rpc(t,'snapshot')['state']
t1,t2=secrets.token_hex(32),secrets.token_hex(32)
r1=rpc(t1,'register',{'name':'QA Alice '+secrets.token_hex(2)});r2=rpc(t2,'register',{'name':'QA Bruno '+secrets.token_hex(2)})
ck(r1['ok'] and r2['ok'],'register two real accounts')
id1,id2=r1['player']['id'],r2['player']['id']; ck(id1!=id2,'distinct identities')
ck(rpc('0'*64,'snapshot')['error']=='unauthorized','bad token denied')
ck(not rpc(t1,'visit',{'target':id2})['ok'],'nonfriend cannot visit')
ck(rpc(t1,'discover',{'query':'QA'})['ok'],'independent discovery')
code=rpc(t1,'invite_create',request_id='invite.first')['code']
ck(rpc(t1,'invite_revoke',{'code':code})['ok'],'invite revoke')
ck(not rpc(t2,'invite_redeem',{'code':code})['ok'],'revoked invite cannot be redeemed')
code=rpc(t1,'invite_create')['code']
ck(rpc(t2,'invite_redeem',{'code':'colheita://invite/'+code},'redeem.same')['ok'],'redeem link creates pending request')
ck(rpc(t2,'invite_redeem',{'code':'colheita://invite/'+code},'redeem.same').get('replayed'),'invite retry replays')
ck(not rpc(t2,'visit',{'target':id1})['ok'],'request is not friendship until accepted')
ck(rpc(t1,'friend_accept',{'target':id2})['ok'],'owner accepts friendship')
visit=rpc(t2,'visit',{'target':id1});ck(visit['ok'] and 'receipts' not in visit and 'tokens' not in visit and 'inventory' not in visit,'visit omits private inventory and credentials')
ck(rpc(t1,'permissions',{'visits':False,'mischief':False})['ok'],'privacy toggle')
ck(not rpc(t2,'visit',{'target':id1})['ok'],'private farm denies friend')
ck(rpc(t1,'permissions',{'visits':True,'mischief':False})['ok'],'enable friendship visits')
plots=['plot.home.a','plot.home.b','plot.home.c','plot.home.d']
# Three batches earn exactly 12 XP from actual timers, no grants/time injection.
for batch in range(3):
 state=snap(t1)
 if state['inventory']['seeds'].get('crop.carrot',0)<4:ck(farm(t1,'buy_seeds',crop_id='crop.carrot',quantity=4)['ok'],'buy four seeds')
 cycles=[]
 for plot in plots:
  r=farm(t1,'plant',plot_id=plot,crop_id='crop.carrot');ck(r['ok'],'server planting');cycles.append(r['cycle_id'])
 if batch==0:
  ck(rpc(t2,'help',{'target':id1,'plot_id':plots[0],'action':'water'},'help.first')['ok'],'real friend watering')
  ck(rpc(t2,'help',{'target':id1,'plot_id':plots[0],'action':'water'},'help.first').get('replayed'),'help replay')
  ck(not rpc(t2,'mischief',{'target':id1,'plot_id':plots[1]})['ok'],'mischief opt-out enforced')
 time.sleep(2.3)
 for plot,cycle in zip(plots,cycles):ck(farm(t1,'harvest',plot_id=plot,cycle_id=cycle)['ok'],'server readiness/harvest')
 ck(farm(t1,'sell_products',items={'crop.carrot':8})['ok'],'actual earned revenue')
ck(snap(t1)['economy']['xp']==12,'no XP from social or purchasing')
# A foreign actor/farm selector cannot redirect owner commands to another farm.
before=snap(t1)
r=farm(t2,'plant',plot_id='plot.home.a',crop_id='crop.carrot',actor_id=id1,farm_id='farm.'+id1)
ck(r['ok'] and snap(t1)==before,'client actor/farm fields cannot select victim farm')
# One stolen unit; owner always retains >=1.
ck(farm(t1,'buy_seeds',crop_id='crop.carrot',quantity=1)['ok'],'prepare theft crop')
plant=farm(t1,'plant',plot_id=plots[0],crop_id='crop.carrot');ck(plant['ok'],'plant theft crop');time.sleep(2.3)
steal=rpc(t2,'steal',{'target':id1,'plot_id':plots[0]},'steal.same');ck(steal['ok'] and steal['quantity']==1,'server calculates limited theft')
count=snap(t2)['inventory']['products']['crop.carrot']
ck(rpc(t2,'steal',{'target':id1,'plot_id':plots[0]},'steal.same').get('replayed'),'steal replay')
ck(snap(t2)['inventory']['products']['crop.carrot']==count,'replay no extra stock')
time.sleep(1.1)
ck(rpc(t2,'steal',{'target':id1,'plot_id':plots[0]})['error']=='theft_limit','per-cycle theft cap beyond cooldown')
harvest=farm(t1,'harvest',plot_id=plots[0],cycle_id=plant['cycle_id']);ck(harvest['ok'] and harvest['quantity']==1,'owner yield reduced atomically but protected minimum remains')
ck(farm(t1,'guardian_buy')['ok'],'buy guardian with earned currency')
ck(farm(t1,'buy_feed',quantity=2)['ok'],'buy guardian feed')
ck(farm(t1,'guardian_feed')['ok'],'feed guardian')
ck(farm(t1,'buy_seeds',crop_id='crop.carrot',quantity=1)['ok'],'buy protected seed')
plant=farm(t1,'plant',plot_id=plots[0],crop_id='crop.carrot');time.sleep(2.3)
r=rpc(t2,'steal',{'target':id1,'plot_id':plots[0]});ck(r['ok'] and r['action']=='guardian_blocked','fed guardian protects')
# Flowers grow and transfer with persisted popularity, never fabricated.
ck(farm(t1,'buy_seeds',crop_id='crop.rose',quantity=1)['ok'],'flower purchase')
rose=farm(t1,'plant',plot_id=plots[1],crop_id='crop.rose');ck(rose['ok'],'flower plant')
time.sleep(21.5)
ck(farm(t1,'harvest',plot_id=plots[1],cycle_id=rose['cycle_id'])['ok'],'real flower growth')
pop=rpc(t2,'social_state')['popularity']
ck(rpc(t1,'gift',{'target':id2,'product':'crop.rose'},'gift.same')['ok'],'flower transfer between accounts')
ck(snap(t2)['inventory']['products'].get('crop.rose',0)==1,'receiver owns flower')
ck(rpc(t2,'social_state')['popularity']==pop+1,'popularity from gift')
ck(rpc(t1,'gift',{'target':id2,'product':'crop.rose'},'gift.same').get('replayed'),'gift replay')
ck(snap(t2)['inventory']['products'].get('crop.rose',0)==1,'gift not duplicated')
ck(not rpc(t1,'farm_command',{'type':'buy_feed','quantity':{'bad':1}})['ok'],'malformed quantity denied')
ck(not rpc(t1,'farm_command',{'type':'buy_producer','kind':33})['ok'],'malformed kind denied')
activity=rpc(t1,'social_state')['activity'];ck(any(x['action']=='help' for x in activity) and any(x['action']=='guardian_blocked' for x in activity),'visible social history')
ck(rpc(t1,'block',{'target':id2})['ok'],'block user')
ck(not rpc(t2,'visit',{'target':id1})['ok'] and not rpc(t2,'gift',{'target':id1})['ok'],'blocked user loses visits and transfers')
ck(rpc(t1,'unblock',{'target':id2})['ok'],'unblock without restoring friendship')
ck(not rpc(t2,'visit',{'target':id1})['ok'],'unblock requires renewed consent')
out=Path('.local/backend/test_credentials.json');out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps({'token1':t1,'token2':t2,'id1':id1,'id2':id2,'coins':snap(t1)['economy']['coins']}))
print(f'Authoritative socket integration PASS: {checks} checks, two identities, separate clients, actual server timers; credentials private/ignored')
