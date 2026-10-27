"""Restart/transaction checks using only the ignored test identities."""
import json,socket,secrets,argparse
parser=argparse.ArgumentParser();parser.add_argument("--port",type=int,default=16662);options=parser.parse_args()
from pathlib import Path
c=json.loads(Path('.local/backend/test_credentials.json').read_text());serial=0;checks=0

def call(token,method,args=None,key=None):
 global serial
 serial+=1
 with socket.create_connection(('127.0.0.1',options.port),timeout=4) as s:
  s.sendall((json.dumps({'token':token,'method':method,'args':args or {},'request_id':key or 'recovery.'+secrets.token_hex(8)})+'\n').encode());data=b''
  while b'\n' not in data:
   part=s.recv(65536)
   if not part:break
   data+=part
 return json.loads(data.split(b'\n')[0])
def ck(ok,msg):
 global checks
 checks+=1
 if not ok:raise AssertionError(msg)
a,b=c['token1'],c['token2'];ia,ib=c['id1'],c['id2']
state=call(a,'snapshot');ck(state['ok'] and state['player']['id']==ia,'identity survived server restart');ck(state['state']['economy']['coins']==c['coins'],'coins persisted unchanged')
ck(call(a,'register',{'name':'ignored retry'})['player']['id']==ia,'register retry cannot create a new farm')
ck(call(a,'friend_request',{'target':ib})['ok'],'renew friendship');ck(call(b,'friend_accept',{'target':ia})['ok'],'renewed consent')
# Receipts survive a full server restart.
ck(call(a,'gift',{'target':ib,'product':'crop.rose'},'gift.same').get('replayed'),'gift replay across process restart')
# Mature plants remain available after absence; harvest legitimately for community goal.
s=call(a,'snapshot')['state'];p=s['plots']['plot.home.a']
if p['crop_id']:ck(call(a,'farm_command',{'type':'harvest','plot_id':p['id'],'cycle_id':p['cycle_id']})['ok'],'offline growth survived restart')
s=call(b,'snapshot')['state'];p=s['plots']['plot.home.a']
if p['crop_id']:ck(call(b,'farm_command',{'type':'harvest','plot_id':p['id'],'cycle_id':p['cycle_id']})['ok'],'second player offline growth')
for token in [a,b]:
 count=int(call(token,'snapshot')['state']['inventory']['products'].get('crop.carrot',0))
 if count:ck(call(token,'community_donate',{'quantity':min(3,count)})['ok'],'community contribution consumes owned product')
progress=call(a,'community_state');ck(progress['progress']['total']>=5,'shared real community counter')
ck(call(a,'community_claim',key='community.claim')['ok'],'earned community reward')
ck(call(a,'community_claim',key='community.claim').get('replayed'),'community reward replay')
ck(not call(a,'community_claim')['ok'],'new ID cannot duplicate community reward')
# Malformed/unauthorized arguments must fail without crashing server.
ck(not call(a,'farm_command',{'type':'buy_producer','kind':42})['ok'],'bad kind denied')
ck(not call(a,'farm_command',{'type':'buy_feed','quantity':-1})['ok'],'negative feed denied')
ck(not call(a,'visit',{'target':[]})['ok'],'bad target denied')
ck(call(a,'snapshot')['ok'],'server remains healthy')
print(f'Social recovery/community PASS: {checks} checks; persisted identities, economy and receipts across server restart')
