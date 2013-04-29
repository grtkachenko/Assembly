import os


def test(file):
    f = open(file, "r")
    lines = f.readlines()
    for i in range(0, len(lines)):
        lines[i] = lines[i].replace("\n", "")
        lines[i] = lines[i].replace("\r", "")
        
    input = lines[0]
    output = lines[1]

    lines_output = os.popen("./a.out " + input).readlines()
    
    if (len(lines_output) != 1) or (lines_output[0] != output):
        print file + ": error"
    else:
        print file + ": ok"
    
    
test_files = os.listdir(".")
for file in test_files:
    if file.endswith("txt"):
        test(file)
