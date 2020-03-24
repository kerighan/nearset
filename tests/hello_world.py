from nearset import NearSet


ns = NearSet(lambda x: len(x))
ns["salut"] = "salut"
ns["comment"] = "comment"
ns["ça"] = "çaut"

print(ns.nodes[:2])
