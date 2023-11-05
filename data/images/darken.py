#!/usr/bin/python
import os

pairs = [(f, f.replace(".svg", "_dark.svg")) 
         for f in os.listdir(".") if f.endswith(".svg")]

for (l, d) in pairs:
    with open(l, "r") as fl, open(d,"w") as fd:
        fd.write(fl.read().replace("#000000", "#a0a0a0"))
    os.system(f"inkscape {d} -o {d.replace('.svg', '.png')}")

