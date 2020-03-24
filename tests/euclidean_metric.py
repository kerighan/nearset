from nearset import NearSet
from sklearn.datasets import make_blobs
from tqdm import tqdm
import numpy as np


def rdist(x, y):
    return np.sum((x - y)**2)


def query_dist(x):
    def func(y):
        return rdist(x, y)
    return func


N = 100000
X, y = make_blobs(N, n_features=100, centers=50)
ns = NearSet(query_dist(X[0]), max_size=10)

for i in tqdm(range(X.shape[0])):
    ns[i] = X[i]

print(ns.nodes[0].order)
print(ns.nodes[1].order)
print(ns.nodes[2].order)
