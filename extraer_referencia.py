import xml.etree.ElementTree as E, json, sys
from pathlib import Path
root=E.parse(sys.argv[1])
def pos(s):return tuple(map(int,s.strip('()').split(',')))
models={}
for c in root.findall('circuit')[:2]:
 parent={}
 def find(x):
  parent.setdefault(x,x)
  if parent[x]!=x:parent[x]=find(parent[x])
  return parent[x]
 def union(a,b):parent[find(a)]=find(b)
 for w in c.findall('wire'):union(pos(w.get('from')),pos(w.get('to')))
 comps=[(p.get('name'),pos(p.get('loc')),{a.get('name'):a.get('val') for a in p.findall('a')}) for p in c.findall('comp')]
 for typ,p,a in comps:
  if typ=='Tunnel':union(p,a['label'])
 labels={}
 for typ,p,a in comps:
  if typ=='Tunnel':labels.setdefault(find(p),[]).append(a['label'])
 def label(p):
  ls=labels.get(find(p),[])
  assert ls, (c.get('name'),p,'NO LABEL')
  return sorted(set(ls),key=lambda s:(s.startswith('T_'),len(s),s))[0]
 defs={}
 for typ,(x,y),a in comps:
  if typ in ['AND Gate','OR Gate','NOT Gate']:
   ins=[label((x-30,y))] if typ=='NOT Gate' else [label((x-50,y-20)),label((x-50,y+20))]
   defs[label((x,y))]=(typ.split()[0],ins)
 inputs=[a['label'] for typ,p,a in comps if typ=='Pin' and a.get('type')!='output' and a['label'] not in ['CLK','Reset']]
 outputs=[a['label'] for typ,p,a in comps if typ=='Pin' and a.get('type')=='output']
 state=['C2','C1','C0'] if c.get('name')=='Moore' else ['P2','P1','P0']
 def evaluate(env,n):
  if n in env:return env[n]
  if n not in defs:
   aliases=labels[find(n)]
   for alt in aliases:
    if alt in env:return env[alt]
    if alt in defs:n=alt;break
  op,ins=defs[n];v=[evaluate(env,i) for i in ins]
  return int(not v[0]) if op=='NOT' else int(all(v)) if op=='AND' else int(any(v))
 rows=[]
 for s in range(8):
  for u in range(2**len(inputs)):
   env=dict(zip(state,[(s>>i)&1 for i in [2,1,0]]));env.update(zip(inputs,[(u>>i)&1 for i in range(len(inputs)-1,-1,-1)]))
   ns=sum(evaluate(env,'D'+n)<<(2-i) for i,n in enumerate(state))
   out={n:evaluate(env,n) for n in outputs}
   rows.append(dict(state=s,input=u,next=ns,outputs=out))
 models[c.get('name')]=dict(inputs=inputs,outputs=outputs,state=state,defs=defs,rows=rows)

M={(r['state'],r['input']):r for r in models['Moore']['rows']}
P={(r['state'],r['input']):r for r in models['Mealy']['rows']}
lines=[]
for c in range(8):
 for p in range(8):
  for u in range(32):
   mo=M[c,0]['outputs']
   pay=P[p,(mo['MODE15']<<4)|(mo['MODE25']<<3)|(u&7)]
   ctrl=M[c,((u>>3)<<1)|pay['outputs']['COMPLETE']]
   names=['MODE15','MODE25','IMPRIME15','IMPRIME25']
   values=[ctrl['outputs'][k] for k in names]
   values += [pay['outputs'][k] for k in ['COMPLETE','C5','C10','C15']]
   bits=int(''.join(map(str,values)),2)
   lines.append(f"{(ctrl['next']<<11)|(pay['next']<<8)|bits:04x}")
out=Path(sys.argv[2]) if len(sys.argv)>2 else Path('referencia.mem')
out.write_text('\n'.join(lines)+'\n')
print(f'{len(lines)} filas extraidas en {out}')
