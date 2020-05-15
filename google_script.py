#!/softwares/anaconda3/envs/myenv/bin/python
import pandas as pd
import numpy as np
import requests
import json
import urllib

def suggest(query):
    desc = query.lower()
    desc = desc.replace('incorporated','')
    desc = desc.replace(' inc','')
    desc = desc.replace('.','')
    desc = desc.replace(',','')
    desc = desc.strip()
    #query = 'Verizon Wireless vs'
    desc = desc + ' vs'
    q = {'q': desc}
    qs = urllib.parse.urlencode(q)
    url = 'https://www.google.co.in/complete/search?'+ str(qs) +'&cp=8&client=psy-ab&xssi=t&gs_ri=gws-wiz&hl=en-IN&authuser=0&psi=gIS1XquBHvyH4-EPrrObmA0.1588954240905&ei=gIS1XquBHvyH4-EPrrObmA0'
    resp = requests.get(url)
    text = resp.text
    #print(text)
    suggestions = []
    #print(text)
    for it in text.split('["')[1:]:
        #print(it)
        iters = it.split(r'\u003cb\u003e')[1:]
        #print(iters)
        for iter in iters:
            suggestions.append(iter.split('\\')[0].strip())
    return ','.join(suggestions)

if __name__ == '__main__':
    txt = ''
    with open('Suppliers.txt','r') as f:
        txt = f.read()
    suppliers = txt.split('\n')
    results = []
    for supplier in suppliers:
        results.append(suggest(supplier))
    df = pd.DataFrame(data={"Query":suppliers,"Results":results})
    df.to_csv('Results.csv',index=False)
        
    