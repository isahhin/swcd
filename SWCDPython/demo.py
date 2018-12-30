import numpy as np

onn = 1000*np.ones([5,5],dtype=np.float32)
print(onn)
a = [ [1,2,3, 4, 5],[4,5,6, 7,8], [7,8,9, 8,9],  [7,8,9, 8,9],  [7,8,9, 8,9]]
a = np.array(a)


idx = np.where(a>2)

print(a)

b = a;
c = b[2:-1]
print(c)

#b = a;
#b[idx] = 1;

#print(b)
#c= b-a
#print(c)
##print(len(idx[0]))
##print(len(idx[1]))


#for j in range(len(idx[0])):
#    print( idx[0][j], idx[1][j] )