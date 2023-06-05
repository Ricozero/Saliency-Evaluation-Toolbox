clear all; close all; clc;

gtDir = '../../Saliency Maps/GT';
salDir = '../../Saliency Maps/JN2-Ablation';
methods = {'BAEFN-44', 'BAS-35', 'EAEFN-50', 'EAS-42', 'EN-44', 'ENa-37', 'RAEFN-48', 'RAS-64', 'TAS-44',};
methods = {'DINet0-47', 'DINet00-80', 'DINet000-49'};
datasets = {'HKU-IS','DUT-OMRON', 'PASCAL-S', 'ECSSD', 'SOD', 'DUTS-TE'};

gtDir = '../../Saliency Maps/GT/SOC-TE-Attr';
salDir = '../../Saliency Maps/JN2-SOC';
methods = {'DINetGA-48'};
datasets = {'All', 'AC', 'BO', 'CL', 'HO', 'MB', 'OC', 'OV', 'SC', 'SO'};

gtDir = '../../Saliency Maps/GT';
salDir = '../../Saliency Maps/FD';
methods = {'DINet-FD-15', 'DINet-FD-pretrain-24', 'RAS-FD-19', 'RAS-FD-pretrain-21', 'TAEFN-FD-23', 'TAEFN-FD-pretrain-25'};
datasets = {'FDD-TE'};

gtDir = '../../Saliency Maps/GT';
salDir = '../../Saliency Maps/Traffic';
methods = {'Ours', 'U2Net', 'RASNet', 'SAMNet', 'MINet'};
datasets = {'Traffic-TE'};

for method = methods
    fprintf('Method: %s\n',char(method));
    for dataset = datasets
        %set dataset path and saliency map result path.
        fprintf('Dataset: %s\n',char(dataset))
        method = char(method);
        dataset = char(dataset);
        gtPath = [gtDir '/' dataset '/'];
        salPath = [salDir '/' method '/' dataset '/'];
        missingNum = 0;

        %obtain the total number of image (ground-truth)
        imgFiles = dir(gtPath);
        imgNUM = length(imgFiles)-2;

        %evaluation score initilization.
        Smeasure=zeros(1,imgNUM);
        Emeasure=zeros(1,imgNUM);
        Fmeasure=zeros(1,imgNUM);
        MAE=zeros(1,imgNUM);
        F_wm=zeros(1,imgNUM);

        tic;
        for i = 1:imgNUM

            if mod(i,100) == 0
                fprintf('Evaluating: %d/%d\n',i,imgNUM);
            end

            name =  imgFiles(i+2).name;
            %name = name(:,3:10);

            %load gt
            gt = imread([gtPath name]);

            if numel(size(gt))>2
                gt = rgb2gray(gt);
            end
            if ~islogical(gt)
                gt = gt(:,:,1) > 128;
            end

            %load saliency
            if exist([salPath name],'file') == 0
                missingNum = missingNum + 1;
                fprintf('Missing %s\n',[salPath name]);
                continue
            else
                sal  = imread([salPath name]);
            end

            %check size
            if size(sal, 1) ~= size(gt, 1) || size(sal, 2) ~= size(gt, 2)
                sal = imresize(sal,size(gt));
                imwrite(sal,[salPath name]);
                fprintf('Error occurs in the path: %s!!!\n', [salPath name]);
            end

            sal = im2double(sal(:,:,1));

            %normalize sal to [0, 1]
            sal = reshape(mapminmax(sal(:)',0,1),size(sal));

            Smeasure(i) = StructureMeasure(sal,logical(gt));
            temp = Fmeasure_calu(sal,double(gt),size(gt)); % Using the 2 times of average of sal map as the threshold.
            Fmeasure(i) = temp(3);

            MAE(i) = mean2(abs(double(logical(gt)) - sal));

            %You can change the method of binarization method. As an example, here just use adaptive threshold.
            threshold =  2* mean(sal(:)) ;
            if ( threshold > 1 )
                threshold = 1;
            end
            Bi_sal = zeros(size(sal));
            Bi_sal(sal>threshold)=1;
            Emeasure(i) = Enhancedmeasure(Bi_sal,gt);
        end

        toc;

    %     Sm = mean2(Smeasure);
    %     Fm = mean2(Fmeasure);
    %     Em = mean2(Emeasure);
    %     mae = mean2(MAE);

        realNum = imgNUM - missingNum;
        Sm = sum(Smeasure) / realNum;
        Fm = sum(Fmeasure) / realNum;
        Em = sum(Emeasure) / realNum;
        mae = sum(MAE) / realNum;
        
        %Fmm = max(Fmeasure);
        %display(Fmm);
        
        fid = fopen([salDir '/' method '/log.txt'], 'a');
        fprintf(fid, '%s: Emeasure = %.4f, Smeasure = %.4f, Fmeasure = %.4f, MAE = %.4f\n', dataset, Em, Sm, Fm, mae);
        fclose(fid);
    end
end