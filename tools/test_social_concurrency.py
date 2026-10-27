"""Concurrent mutation and actual friend animal-help checks on the QA world."""
import argparse,concurrent.futures,json,secrets,socket,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--port',type=int,default=16664);args=p.parse_args()
c=json.loads(Path('.local/backend/test_credentials.json').read_text());a,b=c['token1'],c['token2'];ia,ib=c['id1'],c['id2'];checks=0

def rpc(token,method,body=None,key=None):
 with socket.create_connection(('127.0.0.1',args.port),timeout=5) as s:
  s.sendall((json.dumps({'token':token,'method':method,'args':body or {},'request_id':key or secrets.token_hex(12)})+'\n').encode());data=b''
  while b'\n' not in data:
   part=s.recv(65536)
   if not part:break
   data+=part
 return json.loads(data.split(b'\n')[0])
def ck(ok,message):
 global checks
 checks+=1
 if not ok:raise AssertionError(message)
def state(token):return rpc(token,'snapshot')['state']
old=state(a); op='concurrent.'+secrets.token_hex(8);command={'type':'buy_feed','quantity':1,'price':0,'coins':999999}
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 futures=[pool.submit(rpc,a,'farm_command',command,op) for _ in range(2)];results=[x.result() for x in futures]
ck(all(x['ok'] for x in results) and sum(bool(x.get('replayed')) for x in results)==1,'concurrent same operation serialized/replayed')
new=state(a);ck(new['economy']['coins']==old['economy']['coins']-2 and new['features']['feed']==old['features']['feed']+1,'one server-priced debit despite forged price/coins')
ck(not rpc(a,'farm_command',{'type':'buy_feed','quantity':2},op)['ok'],'operation ID cannot be repurposed')
buy=rpc(a,'farm_command',{'type':'buy_producer','kind':'chicken'});ck(buy['ok'],'real chicken bought from earned coins')
ck(rpc(b,'farm_command',{'type':'buy_feed','quantity':5})['ok'],'helper buys food')
before_owner=state(a)['features']['feed'];before_helper=state(b)['features']['feed']
ck(rpc(b,'animal_help',{'target':ia,'id':buy['id']})['ok'],'friend starts production with own food')
ck(state(a)['features']['feed']==before_owner and state(b)['features']['feed']==before_helper-1,'no food duplication in cross-account help')
time.sleep(5.2)
p=state(a)['features']['producers'][buy['id']]
collect=rpc(a,'farm_command',{'type':'producer_collect','id':buy['id'],'cycle':p['cycle']});ck(collect['ok'],'owner collects actual helped production')
ck(state(a)['features']['goods']['egg']==2,'eggs belong to owner')
print(f'Concurrent/animal social PASS: {checks} checks; serialized retry, server price and atomic cross-farm food')
