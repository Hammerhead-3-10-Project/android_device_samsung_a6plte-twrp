#!/usr/bin/env python3
"""Print TRANSACTION_* constants of a class (default android.os.IVold$Stub) from classes*.dex files."""
import struct, sys, glob
def uleb(d,p):
    r=0;s=0
    while True:
        b=d[p];p+=1;r|=(b&0x7f)<<s;s+=7
        if not b&0x80:break
    return r,p
def parse(path,target):
    d=open(path,'rb').read()
    if d[:3]!=b'dex': return None
    str_sz,str_off,type_sz,type_off,proto_sz,proto_off,field_sz,field_off,meth_sz,meth_off,cls_sz,cls_off=struct.unpack('<12I',d[56:104])
    def sstr(i):
        off=struct.unpack('<I',d[str_off+4*i:str_off+4*i+4])[0]
        _,p=uleb(d,off); e=d.index(b'\0',p); return d[p:e].decode('utf8','replace')
    def tname(i):
        return sstr(struct.unpack('<I',d[type_off+4*i:type_off+4*i+4])[0])
    for c in range(cls_sz):
        ci,acc,sup,ifc,src,ann,cdo,svo=struct.unpack('<8I',d[cls_off+32*c:cls_off+32*c+32])
        if tname(ci)!=target: continue
        res=[]
        # class data
        p=cdo; sf,p=uleb(d,p); inf,p=uleb(d,p); dm,p=uleb(d,p); vm,p=uleb(d,p)
        fidx=0; names=[]
        for i in range(sf):
            diff,p=uleb(d,p); _,p=uleb(d,p); fidx+=diff
            fcls,ftype,fname=struct.unpack('<HHI',d[field_off+8*fidx:field_off+8*fidx+8])
            names.append(sstr(fname))
        # static values
        vals=[]
        if svo:
            p=svo; n,p=uleb(d,p)
            for i in range(n):
                hdr=d[p];p+=1; t=hdr&0x1f; arg=hdr>>5
                if t==0x04: # int
                    v=int.from_bytes(d[p:p+arg+1],'little',signed=True);p+=arg+1;vals.append(v)
                elif t==0x17: # string idx
                    v=int.from_bytes(d[p:p+arg+1],'little');p+=arg+1;vals.append(sstr(v))
                elif t in (0x00,0x02,0x03,0x06,0x10,0x11,0x18,0x19,0x1a,0x1b): p+=arg+1;vals.append(None)
                elif t in (0x1e,0x1f): vals.append(None)
                else: vals.append(None); p+=arg+1
        return list(zip(names,vals))
    return None
target=sys.argv[1] if len(sys.argv)>1 else 'Landroid/os/IVold$Stub;'
for f in sys.argv[2:]:
    r=parse(f,target)
    if r:
        print('#',f)
        for n,v in r: print(f'{n}\t{v}')
