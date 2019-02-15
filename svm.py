import numpy as np
import sklearn
import sklearn.preprocessing

rows = 125
X = np.zeros([rows, 2], dtype=np.float32)
y = np.zeros([rows], dtype=np.int32)
fid = open('feature.txt')
for num,line in enumerate(fid):
    print num, 'sep', line
    X[num,:] = np.float32(line.split('\t')[0:2])
    y[num] = np.int32(line.split('\t')[-1].replace('\t\n', ''))
fid.close()

X2 = sklearn.preprocessing.scale(X)
y2 = np.copy(y)

idx = np.arange(rows)
np.random.shuffle(idx)
X3 = X2[idx, :]
y3 = y2[idx]

x_train = np.copy(X3[0:80, :])
y_train = np.copy(y3[0:80])
x_val = np.copy(X3[80:125, :])
y_val = np.copy(y3[80:125])

from sklearn.svm import SVC
clf = SVC()
clf.fit(x_train,y_train)

pred_y = clf.predict(x_val) 
result = (pred_y==y_val)
result_rate = np.mean(result)

