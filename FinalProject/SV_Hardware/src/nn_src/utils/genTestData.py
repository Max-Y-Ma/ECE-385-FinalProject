import sys

outputPath = "../testData/"
headerFilePath = "../testData/"

try:
    import cPickle as pickle
except:
    import pickle
import gzip
import numpy as np

dataWidth = 1                    #specify the number of bits in test data
IntSize = 1 #Number of bits of integer portion including sign bit

try:
    testDataNum = int(sys.argv[1])
except:
    testDataNum = 3

def DtoB(num,dataWidth,fracBits):                        #funtion for converting into two's complement format
    if num >= 0:
        num = num * (2**fracBits)
        d = int(num)
    else:
        num = -num
        num = num * (2**fracBits)        #number of fractional bits
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2**dataWidth - num
    return d


def load_data():
    f = gzip.open('mnist.pkl.gz', 'rb')         #change this location to the repository where MNIST dataset sits
    try:
        training_data, validation_data, test_data = pickle.load(f,encoding='latin1')
    except:
        training_data, validation_data, test_data = pickle.load(f)
    f.close()
    return (training_data, validation_data, test_data)

def genTestData(dataWidth,IntSize,testDataNum):
    dataHeaderFile = open(headerFilePath+"dataValues.h","w")
    dataHeaderFile.write("int dataValues[]={")
    tr_d, va_d, te_d = load_data()
    test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]

    # Convert to Choosen Binary Representation
    threshold = 0.8
    for x in test_inputs:
        newx = []
        for value in x[0]:
            if (value > threshold):
                newx.append(1)
            else:
                newx.append(0)
        x[0] = newx

    x = len(test_inputs[0][0])
    d=dataWidth-IntSize
    count = 0
    fileName = 'test_data.txt'
    f = open(outputPath+fileName,'w')
    fileName = 'visual_data'+str(te_d[1][testDataNum])+'.txt'
    g = open(outputPath+fileName,'w')
    for i in range(0,x):
        dInDec = DtoB(test_inputs[testDataNum][0][i],dataWidth,d)
        myData = bin(dInDec)[2:]
        dataHeaderFile.write(str(dInDec)+',')
        f.write(myData+'\n')
        if test_inputs[testDataNum][0][i]>0:
            g.write(str(1)+' ')
        else:
            g.write(str(0)+' ')
        count += 1
        if count%28 == 0:
            g.write('\n')
    g.close()
    f.close()
    dataHeaderFile.write('0};\n')
    dataHeaderFile.write('int result='+str(te_d[1][testDataNum])+';\n')
    dataHeaderFile.close()
        
        
def genAllTestData(dataWidth,IntSize):
    tr_d, va_d, te_d = load_data()
    test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]

    # Convert to Choosen Binary Representation
    threshold = 0.8
    for x in test_inputs:
        newx = []
        for value in x[0]:
            if (value > threshold):
                newx.append(1)
            else:
                newx.append(0)
        x[0] = newx

    x = len(test_inputs[0][0])
    d=dataWidth-IntSize
    for i in range(len(test_inputs)):
        if i < 10:
            ext = "000"+str(i)
        elif i < 100:
            ext = "00"+str(i)
        elif i < 1000:
            ext = "0"+str(i)
        else:
            ext = str(i)
        fileName = 'test_data_'+ext+'.txt'
        f = open(outputPath+fileName,'w')
        for j in range(0,x):
            dInDec = DtoB(test_inputs[i][0][j],dataWidth,d)
            myData = bin(dInDec)[2:]
            f.write(myData+'\n')
        f.write(bin(DtoB((te_d[1][i]),dataWidth,0))[2:])
        f.close()



if __name__ == "__main__":
    genTestData(dataWidth, IntSize, testDataNum = 20)
    # genAllTestData(dataWidth, IntSize)
