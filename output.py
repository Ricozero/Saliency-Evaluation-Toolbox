from os.path import join
import os

#root = '../Saliency Maps/JN2-New'
#datasets = ['HKU-IS', 'ECSSD', 'PASCAL-S', 'SOD', 'DUTS-TE', 'DUT-OMRON']
#metrics = ['Fmeasure', 'MAE', 'Smeasure']

# root = '../Saliency Maps/JN2-SOC'
# datasets = ['All', 'AC', 'BO', 'CL', 'HO', 'MB', 'OC', 'OV', 'SC', 'SO']
# metrics = ['Emeasure', 'MAE', 'Smeasure']

root = '../Saliency Maps/Traffic'
datasets = ['Traffic-TE']
metrics = ['Fmeasure', 'MAE', 'Smeasure']

methods = os.listdir(root)
#results = np.zeros(len(methods), len(datasets), len(metrics))
results = [[['  -  ' for _ in range(len(metrics))] for _ in range(len(datasets))] for _ in range(len(methods))]
for i, method in enumerate(methods):
    with open(join(root, method, 'log.txt')) as f:
        text = f.readlines()
    for line in text:
        if line == '\n':
            continue
        j = datasets.index(line[0:line.find(':')])
        for k, metric in enumerate(metrics):
            pos = line.find(metric) + len(metric) + 4
            s = line[pos:pos + 5]
            results[i][j][k] = s

with open('results-Traffic.txt', 'w') as f:
    for i in range(len(methods)):
        f.write(methods[i] + ': \t')
        for j in range(len(datasets)):
            for k in range(len(metrics)):
                f.write(results[i][j][k] + ', ')
            f.write('\t')
        f.write('\n')

