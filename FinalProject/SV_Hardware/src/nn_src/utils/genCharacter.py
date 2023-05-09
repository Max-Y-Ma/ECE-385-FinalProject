fileName = "../testData/test_data_0099.txt"

def toHex(binaryString):
    if (binaryString == "0000"):
        return "0"
    if (binaryString == "0001"):
        return "1"
    if (binaryString == "0010"):
        return "2"
    if (binaryString == "0011"):
        return "3"
    if (binaryString == "0100"):
        return "4"
    if (binaryString == "0101"):
        return "5"
    if (binaryString == "0110"):
        return "6"
    if (binaryString == "0111"):
        return "7"
    if (binaryString == "1000"):
        return "8"
    if (binaryString == "1001"):
        return "9"
    if (binaryString == "1010"):
        return "A"
    if (binaryString == "1011"):
        return "B"
    if (binaryString == "1100"):
        return "C"
    if (binaryString == "1101"):
        return "D"
    if (binaryString == "1110"):
        return "E"
    if (binaryString == "1111"):
        return "F"


def genCharacter():
    f = open(fileName, "r")

    # Format Image Array
    print("static alt_u32 image[IMG_HEIGHT] = {")
    for i in range(28):
        hex_row = "0x0"
        for j in range(7):
            binary_row = ""
            for k in range(4):
                binary_row += (f.readline().strip())
            hex_row += toHex(binary_row)
        if (i == 27):
            print("\t" + hex_row)
        else:
            print("\t" + hex_row + ',')
    print("};")

    # Format Expected Value
    expected = (f.readline().strip())
    expected_num = 0
    count = len(expected)    
    for bit in expected:
        expected_num += int(bit) * 2 ** (count - 1)
        count -= 1
    print("Expected Number:{} " .format(expected_num))

    f.close()

if __name__ == "__main__":
    genCharacter()